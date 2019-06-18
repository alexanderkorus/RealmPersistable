//
//  RealmSwift+Codable.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 16.06.19.
//

import Foundation
import RealmSwift

// swiftlint:disable line_length identifier_name
// stolen functions from the Swift stdlib
// https://github.com/apple/swift/blob/2e5817ebe15b8c2fc2459e08c1d462053cbb9a99/stdlib/public/core/Codable.swift
//
public func assertTypeIsEncodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Encodable.Type else {
        if T.self == Encodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Encodable because Encodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Encodable because \(T.self) does not conform to Encodable.")
        }
    }
}

public func assertTypeIsDecodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Decodable.Type else {
        if T.self == Decodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Decodable because Decodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Decodable because \(T.self) does not conform to Decodable.")
        }
    }
}

public extension Encodable {
    func __encode(to container: inout SingleValueEncodingContainer) throws { try container.encode(self) }
    func __encode(to container: inout UnkeyedEncodingContainer)     throws { try container.encode(self) }
    func __encode<Key>(to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws { try container.encode(self, forKey: key) }
}

public extension Decodable {
    // Since we cannot call these __init, we'll give the parameter a '__'.
    fileprivate init(__from container: SingleValueDecodingContainer)   throws { self = try container.decode(Self.self) }
    fileprivate init(__from container: inout UnkeyedDecodingContainer) throws { self = try container.decode(Self.self) }
    fileprivate init<Key>(__from container: KeyedDecodingContainer<Key>, forKey key: Key) throws { self = try container.decode(Self.self, forKey: key) }
}


extension RealmOptional : Encodable where Value : Encodable {
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(Value.self, in: type(of: self))
        
        var container = encoder.singleValueContainer()
        if let v = self.value {
            try (v as Encodable).encode(to: encoder)  // swiftlint:disable:this force_cast
        } else {
            try container.encodeNil()
        }
    }
}

extension RealmOptional : Decodable where Value : Decodable {
    public convenience init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self.init()
        assertTypeIsDecodable(Value.self, in: type(of: self))
        
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            let metaType = (Value.self as Decodable.Type) // swiftlint:disable:this force_cast
            let element = try metaType.init(from: decoder)
            self.value = (element as! Value)  // swiftlint:disable:this force_cast
        }
    }
}
extension List : Decodable where Element : Decodable {
    public convenience init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self.init()
        assertTypeIsDecodable(Element.self, in: type(of: self))
        
        let metaType = (Element.self as Decodable.Type) // swiftlint:disable:this force_cast
        let container = try? decoder.unkeyedContainer()
        if var container = container {
            while !container.isAtEnd {
                let element = try metaType.init(__from: &container)
                self.append(element as! Element) // swiftlint:disable:this force_cast
            }
        } else {
            
        }
    }
}

extension List : Encodable where Element : Decodable {
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(Element.self, in: type(of: self))
        
        var container = encoder.unkeyedContainer()
        for element in self {
            // superEncoder appends an empty element and wraps an Encoder around it.
            // This is normally appropriate for encoding super, but this is really what we want to do.
            let subencoder = container.superEncoder()
            try (element as! Encodable).encode(to: subencoder) // swiftlint:disable:this force_cast
        }
    }
}

public class RealmOptionalBool: Object, Codable {
    @objc dynamic var id: Int = 0
    private var boolValue = RealmOptional<Bool>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode(Bool.self)
            boolValue = RealmOptional(value)
            id = value == true ? 1 : 0
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueEncoder = encoder.singleValueContainer()
        if let v = self.value {
            try singleValueEncoder.encode(v)
        } else {
            try singleValueEncoder.encodeNil()
        }
    }
    
    var value: Bool? {
        return boolValue.value
    }
    
    var falseOrValue: Bool {
        return boolValue.value ?? false
    }
}

public class RealmOptionalInt: Object, Codable {
    private var intValue = RealmOptional<Int>()
    
    override public static func primaryKey() -> String? {
        return "intValue"
    }
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let singleValueContainer = try decoder.singleValueContainer()
        
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode(Int.self)
            intValue = RealmOptional(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueEncoder = encoder.singleValueContainer()
        if let v = self.value {
            try singleValueEncoder.encode(v)
        } else {
            try singleValueEncoder.encodeNil()
        }
    }
    
    public var value: Int? {
        return intValue.value
    }
    
    public var zeroOrValue: Int {
        return intValue.value ?? 0
    }
}



public class RealmList<T: RealmCollectionValue & Codable>: Object, Codable {
    private let listValue = List<T>()
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        
        
        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let l = try singleValueContainer.decode([T].self)
            print(l)
            self.listValue.append(objectsIn: l)
            print("LIST_VALUE:")
            print(self.listValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueEncoder = encoder.singleValueContainer()
        try singleValueEncoder.encode(self.list)
        
    }
    
    public var list: List<T> {
        return listValue
    }
}
