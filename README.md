# RealmPersistable

[![CI Status](https://img.shields.io/travis/alexanderkorus/RealmPersistable.svg?style=flat)](https://travis-ci.org/alexanderkorus/RealmPersistable)
[![Version](https://img.shields.io/cocoapods/v/RealmPersistable.svg?style=flat)](https://cocoapods.org/pods/RealmPersistable)
[![License](https://img.shields.io/cocoapods/l/RealmPersistable.svg?style=flat)](https://cocoapods.org/pods/RealmPersistable)
[![Platform](https://img.shields.io/cocoapods/p/RealmPersistable.svg?style=flat)](https://cocoapods.org/pods/RealmPersistable)

This library is a personal toolset to extend RealmSwift with handsome extensions, whose improve usability of Realm based on best practises from gists and other libraries like EasyRealm. Code from third party Libraries are copied directly to the project to be avoid multiple dependency.

## Features

* RealmManager to initialize realm Configuration
* Automatic Realm Migration without taking care about increasing schemaVersion
* CRUD functions directly for Persistable Models
* Diffing option when saving collection of objects
* Cascade Deleting

## Requirements

* Swift 5.0
* Deployment Target 11.0
* RealmSwift 3.16.1

## Installation

RealmPersistable is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RealmPersistable'
```

## Usage

### RealmManager

With the RealmManager you can easily initialize the configuration for Realm. RealmManager
takes care about Migration, so you don't have to change schemaVersion manually. 
If you define a fileUrl in the Config, then it places the file at the specified location when you are using simulator. This is useful if you want to look at the database for example with RealmStudio.

You can also pass a custom migration, if it is neccasary. 

Define a Migration struct and conform it to RealmMigration
```swift
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
                }
            }
        }
    }
}
```

And initialize Realm in the AppDelegate. Pass the migration you have one (optional):

```swift 
RealmManager.default.initialize(with: RealmManager.Config(
    fileUrl: "/Users/Example/Development/localDb.realm",
    shouldUseFilePathWhenSimulator: true,
    migration: ExampleRealmMigration(),
    objectTypes: [
        Model.self // define the models which are Object / Persistables
    ])
)
```

### Persistable Conformance

When you using RealmPersistable and enable different functions to save, edit, delete and query
your Realm models have to conform the Persistable protocol. The typealias is the Type of  
the primary key.

Limitations: Your models forced to have a primary key.

```swift

final class Model: Object, Persistable {

    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var count: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    typealias Id = String
}
```

### Save / Create / Edit objects

To save an object you have two possibilities. For example if you get the data from an API
you can call save, to persist the object to the realm database:

```swift
let model: Model = getModelFromAPI()
model.save()
```

If you creating an object by yourself, you can use the create functions to edit the properties before:
````swift
Model.create {
    $0.id = UUID().uuidString
    $0.type = "CreatedType"
    $0.count = 3
}
````

If you only want to edit a object, you can use the edit method. It uses the UpdatePolicy.modified to update only changed properties in the model:
```swift
Model.edit {
    $0.type = "EditedModel"
}
```

### Unmanaged / Managed objects

You can easisly identify if an object is managed or unmanaged by using isManaged:
```swift
model.isManaged // Return true if realm != nil and return false if realm == nil
model.unmanged // Return the managed version of the object
model.unmanaged // Return the unmanaged version of the object
```

### Get 

If you want to query a model (managed) from the database you can easily call get:
```swift
let model = Model.get(forPrimaryKey: "id")
```

If you want query all objects of a specific model from the database you can use the following methods
```swift
let modelArray: [Model] = Model.all() // returns all models as array (managed)
let modelResults: Results<Model>? = Model.allResults() // returns all models as result set (to use for notifications)
```

### Collections

You can save / delete a collection of objects with one line. 

Save:
```swift
let models: [Model] = getModelsFromAPI()
models.saveAll() // Save all without diffing results

models.saveAll(diffingPolicy: DiffingPolicy(
    shouldDiffing: true,
    cascading: true
))
```
DiffingPolicy indicate, if the objects which are not contains in the current array should deleted
from the database. Cascading takes care if the objects to deleted should be cascade.

Delete all objects from the collection:
```swift
let models: [Model] = getModelsFromAPI()
models.deleteAll(cascading: true) // cascading delete
```

You can delete all objects of a Model by using the static deleteAll method:
```swift
Model.deleteAll()
```

### Helper

To transform an result set to an managed or unmanaged array of models, use can easily doing the following:

```swift
let resultModels = Model.allResults()
self.models = resultModels.toArray(ofType: Model.self) // returns managed array of objects
self.models = resultModels.unmanagedArray(Model.self) // returns unmanaged array of objects
```

## ToDo

* Code documentation
* Example for Edit function

## Author

Alexander Korus, alexander.korus@svote.io

## License

RealmPersistable is available under the MIT license. See the LICENSE file for more info.
