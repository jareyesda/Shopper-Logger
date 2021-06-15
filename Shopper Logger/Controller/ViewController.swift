//
//  ViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var orders: [NSManagedObject] = []
    var filteredData: [String]!
    
    var orderLogger = OrderLoggerManager()
        
    @IBOutlet var orderLog: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderLog.dataSource = self
        orderLog.delegate = self
        
        // Printing filepath for checking data persistance (need SQLite file)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Loading Orders
        orders = orderLogger.loadItems()
        
//        searchTextField.delegate = self
//        searchTextField.showsCancelButton = true
        
        self.orderLog.keyboardDismissMode = .onDrag
        
//        DataManager.shared.firstVC = self
        orderLog.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        orders = orderLogger.loadItems()
       self.orderLog.reloadData()
        
   }
    
    //MARK: - Unwind Segue from order logging form
    @IBAction func unwindToOrderLog(segue: UIStoryboardSegue) {
        //Nothing goes here
    }
}

//MARK: - TableView Delegate and DataSource Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell")
        let order = orders[indexPath.row]
        cell?.textLabel?.text = order.value(forKey: "dateTime") as? String
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewOrder", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ViewOrderViewController {
            
            let orderIndex = (orderLog.indexPathForSelectedRow?.row)!
            let order = orders[orderIndex]
            
            destination.dateTime = order.value(forKey: "dateTime") as? String
            destination.notes = order.value(forKey: "notes") as? String
            if let images = order.value(forKey: "photos") as? Data {
                destination.images = self.imagesFromCoreData(object: images)!
            }
            
        }
    
    }
    
    //MARK: - Function that transform CoreData Binary Data to a UIImage
    func imagesFromCoreData(object: Data?) -> [UIImage]? {
        var retVal = [UIImage]()

        guard let object = object else { return nil }
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
        
        return retVal
    }

}


//extension ViewController: UISearchBarDelegate, UISearchDisplayDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if !searchText.isEmpty {
//            var predicate: NSPredicate = NSPredicate()
//            predicate = NSPredicate(format: "dateTime contains[c] '\(searchText)'")
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            let managedObjectContext = appDelegate.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Order")
//            fetchRequest.predicate = predicate
//            do {
//                orders = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
//            } catch let error as NSError {
//                print("Could not fetch. \(error)")
//            }
//        }
//        orderLog.reloadData()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        isEditing = false
//        orderLog.reloadData()
//    }
//}
