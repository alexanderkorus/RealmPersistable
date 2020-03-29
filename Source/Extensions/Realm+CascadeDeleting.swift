//
//  Realm+Extensions.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 14.06.19.
//

import Foundation
import RealmSwift
import Realm

/**
 This function enables cascade deleting for realm object and safe writing.
 Solution for cascade functions found on
 https://gist.github.com/krodak/b47ea81b3ae25ca2f10c27476bed450c
 and improved with other functions
 */

public protocol CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

extension Realm: CascadeDeleting {
    
    
    /// Delete the passed objects in the realm instance.
    /// When cascading is true, objects will make a cascading delete
    ///
    /// - Parameters:
    ///   - objects: Sequence
    ///   - cascading: Bool
    public func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }
    
    /// Delete the passed object in the realm instance.
    /// When cascading is true, objects will make a cascading delete
    ///
    /// - Parameters:
    ///   - entity: Object
    ///   - cascading: Bool
    public func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadingDelete(entity)
        } else {
            delete(entity)
        }
    }
    
    /// safeWrite to database to ensure, that writes only
    /// performed when it isn't already in a write transaction
    ///
    /// - Parameter block: (() throws -> Void)
    /// - Throws: throws
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }

}

private extension Realm {
    
    private func cascadingDelete(_ object: Object) {
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(object)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object, !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
            delete(element)
        }
    }
    
    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        guard let deletable = element as? CascadeDeletable else { return }
        let computedProperties = (type(of: element).sharedSchema()?.computedProperties ?? []).map { $0.name }
        let propertiesToDelete = ((element.objectSchema.properties.map { $0.name }) + computedProperties).filter { (propertyName) -> Bool in
            deletable.propertiesToCascadeDelete.keys.contains(where: { (name) -> Bool in
                name == propertyName
            })
        }
        propertiesToDelete.forEach {
            guard let value = element.value(forKey: $0) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0..<list._rlmArray.count {
                    guard let realmObject = list._rlmArray.object(at: index) as? RLMObjectBase else { continue }
                    toBeDeleted.insert(realmObject)
                }
            } else if let linkingObjects = value as? LinkingObjects {
                guard let type = deletable.propertiesToCascadeDelete[$0] else { return }
                guard let unrwappedType = type else { fatalError("Object type not specified for cascade delete of linking object") }
                guard let objects = convertLinkingBase(linkingObjects, to: unrwappedType) else { return }
                for index in 0..<objects.count {
                    toBeDeleted.insert(objects[index])
                }
            }
        }
    }
    
	private func convertLinkingBase<Element: Object>(_ linkingObjects: LinkingObjects<Object>, to type: Element.Type) -> LinkingObjects<Element>? {
        let p = unsafeBitCast(linkingObjects, to: Optional<LinkingObjects<Element>>.self)
        return p
    }
}

protocol CascadeDeletable: class {
    var propertiesToCascadeDelete: [String: Object.Type?] { get }
}
