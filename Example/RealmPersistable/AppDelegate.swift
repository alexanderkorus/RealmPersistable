//
//  AppDelegate.swift
//  RealmPersistable
//
//  Created by BigAlKo on 06/14/2019.
//  Copyright (c) 2019 BigAlKo. All rights reserved.
//

import UIKit
import RealmPersistable

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        RealmManager.default.initialize(with: RealmManager.Config(
            fileUrl: "/Users/alko/Developement/toolset-ios/RealmPersistable/Example/localRealm.realm",
            shouldUseFilePathWhenSimulator: true,
            migration: ExampleRealmMigration(),
            objectTypes: [
                Model.self
            ])
        )
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

struct ExampleRealmMigration: RealmMigration {
    
    func migrate(with schemaVersion: UInt64) -> RealmMigrationBlock {
        return { migration, oldSchemaVersion in
            
            if oldSchemaVersion < schemaVersion {
                
                migration.enumerateObjects(ofType: Model.className()) { _, new in
                    
                    if let newValue = new?["count"] as? Int, newValue == 0 {
                        new?["count"] = 1
                    } else {
                        new?["count"] = 2
                    }
                    
                    if let newValue = new?["type"] as? String, newValue == "" {
                        new?["type"] = "MigratedEmpty"
                    } else {
                        new?["type"] = "MigratedNull"
                    }
                    
                }
                
            }
            
        }
    }
    
}
