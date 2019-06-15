//
//  Realm+EasyRealm.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 15.06.19.
//

import Foundation
import RealmSwift
import Realm

/**
 Based on https://github.com/PoissonBallon/EasyRealm
 but without DSL. We have to explicit define the models with Persistable Protocol
 to enable features directly on the realm models.
 */

internal protocol PersistableList {
    func children() -> [Object]
}

extension List: PersistableList {
    internal func children() -> [Object] {
        return self.compactMap { return $0 as? Object }
    }
}


extension Persistable where Self: Object {
    
    public var isManaged: Bool {
        return (self.realm != nil)
    }
    
    public var managed: Self? {
        guard let realm = try? Realm() else { return nil }
        let object = realm.object(ofType: Self.self, forPrimaryKey: self.id)
        return object
    }
    
    public var unmanaged: Self {
        return self.easyDetached()
    }
    
    func detached() -> Self {
        return self.easyDetached()
    }
}


fileprivate extension Object {
     func easyDetached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? Object {
                detached.setValue(detachable.easyDetached(), forKey: property.name)
            } else if let detachable = value as? PersistableList  {
                detached.setValue(detachable.children().compactMap { $0.easyDetached() },forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

internal struct PersistableQueue {
    let realm:Realm
    let queue:DispatchQueue
    
    init?() {
        queue = DispatchQueue(label: UUID().uuidString)
        var tmp:Realm? = nil
        queue.sync { tmp = try? Realm() }
        guard let valid = tmp else { return nil }
        self.realm = valid
    }
}

extension Persistable where Self: Object {
    
    func managed_save(update: Realm.UpdatePolicy) throws -> Self {
        let ref = ThreadSafeReference(to: self)
        guard let rq = PersistableQueue() else {
            throw PersistableError.RealmQueueCantBeCreate
        }
        return try rq.queue.sync {
            guard let object = rq.realm.resolve(ref) else { throw PersistableError.ObjectCantBeResolved }
            rq.realm.beginWrite()
            let ret = rq.realm.create(Self.self, value: object, update: update)
            try rq.realm.commitWrite()
            return ret
        }
    }
    
    func unmanaged_save(update: Realm.UpdatePolicy) throws -> Self {
        let realm = try Realm()
        realm.beginWrite()
        let ret = realm.create(Self.self, value: self, update: update)
        try realm.commitWrite()
        return ret
    }
    
}

public enum PersistableError: Error {
    case RealmQueueCantBeCreate
    case ObjectCantBeResolved
    case ObjectHaveNotPrimaryKey
    case ObjectWithPrimaryKeyNotFound
    case ManagedVersionOfObjectDoesntExist
}
