//
//  Results+Extensions.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 15.06.19.
//

import Foundation
import RealmSwift

public extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        return self.compactMap {
            $0 as? T
        }
    }
    
    func unmanagedArray<T: Persistable>(_ ofType: T.Type) -> [T] {
        return self.compactMap {
            ($0 as? T)?.unmanaged
        }
    }
}
