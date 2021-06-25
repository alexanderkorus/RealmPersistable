//
//  ViewController.swift
//  RealmPersistable
//
//  Created by BigAlKo on 06/14/2019.
//  Copyright (c) 2019 BigAlKo. All rights reserved.
//

import UIKit
import RealmSwift
import RealmPersistable

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var token: NotificationToken?
    private var models: [Model] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let resultModels = Model.allResults()
        
        self.token = resultModels?.observe { [weak self] (changes: RealmCollectionChange<Results<Model>>) -> Void in
            guard let self = self else { return }
            
            switch changes {
                case .initial(let models), .update(let models, _, _, _):
                    self.models = models.unmanagedArray(Model.self)
                    self.tableView.reloadData()
                case .error(let error):
                    print(error.localizedDescription)
            }
            
        }
        
    }
    
    @IBAction func addModelButtonTapped(_ sender: Any) {
        
        Model.create {
            $0.id = UUID().uuidString
            $0.type = "CreatedType"
            $0.count = 3
        }
        
        
        
    }
    
    @IBAction func deleteModelsButtonTapped(_ sender: Any) {
        self.models.deleteAll(cascading: true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "baseCell")
        let model = self.models[indexPath.row]
        cell.textLabel?.text = model.id
        cell.detailTextLabel?.text = "Type: \(model.type) Count: \(model.count)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = self.models[indexPath.row]
        
		
        
    }
}
