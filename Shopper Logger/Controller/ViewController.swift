//
//  ViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import CoreData
import SwipeCellKit

class ViewController: UIViewController {
    
    var orders: [NSManagedObject] = []
    var orderArray: [OrderModel] = []
    
    var orderLogger = OrderLoggerManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    @IBOutlet var orderLog: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderLog.dataSource = self
        orderLog.delegate = self
        
        // Printing filepath for checking data persistance (need SQLite file)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        print(self.orderArray)
        
        // Loading Orders
        orders = orderLogger.loadItems()
        orderArray = orderLogger.coreToOrderArray(orders)
        
        self.orderLog.keyboardDismissMode = .onDrag
                
        orderLog.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Order log appeared")
        DispatchQueue.main.async {
            self.orders = self.orderLogger.loadItems()
            self.orderLog.reloadData()
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell") as! SwipeTableViewCell
        cell.delegate = self
        
        let order = orders[indexPath.row]
        cell.textLabel?.text = order.value(forKey: "dateTime") as? String
        return cell
        
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
                destination.images = self.orderLogger.imagesFromCoreData(object: images)!
            }
            
        }
    
    }

}

//MARK: - SwipeTableViewCell Delegate methods
extension ViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                
                self.context.delete(self.orders[indexPath.row])
                self.orders.remove(at: indexPath.row)
                                
//                self.orderArray = [OrderModel]()
//                
//                for order in self.orderArray {
//                    let orderToSave = Order(context: self.context)
//                    orderToSave.dateTime = order.dateTime
//                    orderToSave.notes = order.notes
//                    orderToSave.photos = order.photos
//                }
//                
//                self.orderLogger.saveOrders(tableViewToReload: self.orderLog)
//                self.orderArray = self.orderLogger.coreToOrderArray(self.orders)
                
                print("Item deleted!")
                print(self.orderArray.count)
                
                self.orderLog.reloadData()
                
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "trash-circle")

            return [deleteAction]
        
    }
    
}
