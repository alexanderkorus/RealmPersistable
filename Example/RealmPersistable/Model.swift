//
//  Model.swift
//  RealmPersistable_Example
//
//  Created by Alexander Korus on 14.06.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RealmPersistable

final class Model: Object, Persistable {
    
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var count: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    typealias Id = String
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.id)
        hasher.combine(self.type)
        hasher.combine(self.count)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Model else { return false }
        guard self.id == object.id else { return false }
        guard self.type == object.type else { return false }
        guard self.count == object.count else { return false }
        return true
    }
}
