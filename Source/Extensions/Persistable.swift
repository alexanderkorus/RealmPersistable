//
//  Persistable.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 14.06.19.
//

import Foundation
import RealmSwift

/**
 This protocol defines the possible function for persistable types
 */
public protocol Persistable where Self: Object {
    
    // Defines the type for the realm primary key
    associatedtype Id: Equatable
    
    // Instance Methods
    func save(update: Realm.UpdatePolicy) -> Self?
    func delete(cascading: Bool)
    func edit(properties: (Self) -> Void)
    
    // Static Methods
    static func get(forPrimaryKey: Id) -> Self?
    static func all() -> [Self]
    static func allResults() -> Results<Self>?
    static func create(properties: (Self) -> Void)
    static func deleteAll(cascading: Bool)
    
    // Properties
    var id: Id { get set }
        
}

public extension Persistable where Self: Object {
    
    @discardableResult
    func save(update: Realm.UpdatePolicy = .all) -> Self? {
        return try? self.saved(update: update)
    }
    
    func saved(update: Realm.UpdatePolicy = .all) throws -> Self {
        return (self.isManaged)
            ? try managed_save(update: update)
            : try unmanaged_save(update: update)
    }
    
    func delete(cascading: Bool = false) {
        
        guard let realm = try? Realm() else { return }
        
        // use self when managed or query if unmanged from databse
        if let object = self.isManaged
            ? self
            : Self.get(forPrimaryKey: self.id) {
        
            try? realm.safeWrite {
                realm.delete(object, cascading: cascading)
            }
        }
        
    }
    
    static func all() -> [Self] {
        
        guard let realm = try? Realm() else { return [] }
        return realm.objects(Self.self).toArray(ofType: Self.self)
        
    }
    
    static func allResults() -> Results<Self>? {
        
        guard let realm = try? Realm() else { return nil }
        return realm.objects(Self.self)
        
    }
    
    
    static func create(properties: (Self) -> Void) {
        
        let object: Self = Self()
        properties(object)
        object.save()
        
    }
    
    static func deleteAll(cascading: Bool = false) {
        guard let realm = try? Realm() else { return }
        realm
            .objects(Self.self)
            .toArray(ofType: Self.self)
            .deleteAll(cascading: cascading)
    }
    
    static func get(forPrimaryKey: Id) -> Self? {
        
        guard let realm = try? Realm() else { return nil }
        return realm.object(ofType: Self.self, forPrimaryKey: forPrimaryKey)
        
    }
    
    func edit(properties: (Self) -> Void) {
        guard let realm = try? Realm() else { return }
        
        // use self when managed or query if unmanged from databse
        if let object = self.isManaged
            ? self
            : Self.get(forPrimaryKey: self.id) {

            try? realm.safeWrite {
				properties(object)
            }


        }
    }
}

public extension Array where Element: Persistable {
    
    /**
    Deletes all objects from database which are not in the current array
    */
    func removeDeletions(cascading: Bool = false) {
        
        guard let realm = try? Realm() else { return }
        
        let persistables = self.map { $0.id }
        
        let removeData = realm.objects(Element.self).toArray(ofType: Element.self).filter {
            !persistables.contains($0.id)
        }
        
        for persistable in removeData {
            persistable.delete()
        }
        
    }
    
    func deleteAll(cascading: Bool = false) {
        self.forEach {
            $0.delete(cascading: cascading)
        }
    }

    
    
    /// Save all realm objects from self in the datebase. If diffingPolicy is set to true
    /// all objects deleted from database which are not in the current array
    /// (with cascading based on policy). Default is set to false for diffing and cascading.
    ///
    /// - Parameters:
    ///   - update: Realm.UpdatePolicy
    ///   - diffingPolicy: DiffingPolicy
    func saveAll(update: Realm.UpdatePolicy = .all, diffingPolicy: DiffingPolicy = DiffingPolicy() ) {
        
        if diffingPolicy.shouldDiffing {
            self.removeDeletions(cascading: diffingPolicy.cascading)
        }
        
        self.forEach {
            $0.save()
        }
        
    }
}


public struct DiffingPolicy {
    
    let shouldDiffing: Bool
    let cascading: Bool
    
    public init(shouldDiffing: Bool = false, cascading: Bool = false) {
        self.shouldDiffing = shouldDiffing
        self.cascading = cascading
    }
    
}
    

