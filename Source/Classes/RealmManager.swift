//
//  RealmManager.swift
//  RealmPersistable
//
//  Created by Alexander Korus on 15.06.19.
//

import Foundation
import RealmSwift

public class RealmManager {
    
    // MARK: - Properties
    public static let `default` = RealmManager()
    fileprivate let defaults = UserDefaults.standard
    fileprivate var config: Realm.Configuration {
        didSet {
            Realm.Configuration.defaultConfiguration = config
        }
    }
    
    private init() {
        self.config = Realm.Configuration.defaultConfiguration
    }
    
    // MARK: - Initialization
    public func initialize(with config: Config) {
        
        var fileUrl: URL? = self.config.fileURL
        
        if config.shouldUseFilePathWhenSimulator && Platform.isSimulator {
            fileUrl = config.fileUrl
        }
        
        // Check if schemaVersion has to increase
        do {
            for objectType in config.objectTypes {
                _ = try Realm().objects(objectType)
            }
        } catch {
            self.schemaVersion = self.schemaVersion + 1
        }
        
        
        self.config = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: self.schemaVersion,
            migrationBlock: config.migration.migrate(with: self.schemaVersion),
            objectTypes: config.objectTypes
        )
        
    }
    
    // MARK: Computed properties
    public var schemaVersion: UInt64 {
        get {
            if let value = defaults.object(forKey: Keys.UserDefaults.schemaVersion) as? UInt64 {
                return value
            } else {
                return 0
            }
        }
        set {
            defaults.set(newValue, forKey: Keys.UserDefaults.schemaVersion)
        }
    }

    // MARK: Value Types
    private struct Platform {
        
        static var isSimulator: Bool {
            return TARGET_OS_SIMULATOR != 0
        }
        
    }
    
    private enum Keys {
        
        enum UserDefaults {
            static let schemaVersion = "schemaVersion"
        }
        
    }
    
    public struct Config {
        var fileUrl: URL?
        var migration: RealmMigration
        var shouldUseFilePathWhenSimulator: Bool
        var objectTypes: [Object.Type]
        
        public init(
            fileUrl: String? = nil,
            shouldUseFilePathWhenSimulator: Bool = false,
            migration: RealmMigration = DefaultMigration(),
            objectTypes: [Object.Type]
        ) {
            if let stringUrl = fileUrl {
                self.fileUrl = URL(fileURLWithPath: stringUrl)
            }
            self.migration = migration
            self.shouldUseFilePathWhenSimulator = shouldUseFilePathWhenSimulator
            self.objectTypes = objectTypes
        }
    }
    
}

public typealias RealmMigrationBlock = (_ migration: Migration, _ oldSchemaVersion: UInt64) -> Void

public protocol RealmMigration {
    func migrate(with schemaVersion: UInt64) -> (_ migration: Migration, _ oldSchemaVersion: UInt64) -> Void
}

public struct DefaultMigration: RealmMigration {
    
    public func migrate(with schemaVersion: UInt64) -> RealmMigrationBlock {
        
        return  { (migration: Migration, oldSchemaVersion: UInt64) -> Void in
            
            if oldSchemaVersion < schemaVersion {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
                // we need to update the version with an empty block to indicate that the schema has been upgraded (automatically) by Realm.
            }
        }
        
    }
    
    public init() {}
    
}
