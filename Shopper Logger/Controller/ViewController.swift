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
        
    @IBOutlet var orderLog: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderLog.dataSource = self
        orderLog.delegate = self
        
        // Printing filepath for checking data persistance (need SQLite file)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Loading Orders
        loadItems()

        let notificationName = NSNotification.Name("reloadLog")
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableview), name: notificationName, object: nil)

    }
    
    @objc func reloadTableview() {
        self.orderLog.reloadData()
    }
    
    //MARK: - Loading items from Core Data function
    func loadItems() {
        
    //1
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      //2
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Order")
        
        // This is to sort the orders -> Most recent first
        let sort = NSSortDescriptor(key: "dateTime", ascending: false)
        fetchRequest.sortDescriptors = [sort]
    
    
      //3
      do {
        orders = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
            
    }
    
    //MARK: - Unwind Segue from order logging form
    @IBAction func unwindToOrderLog(segue: UIStoryboardSegue) {
        //Nothing goes here
    }
    
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

}
