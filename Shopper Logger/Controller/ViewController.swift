//
//  ViewController.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/12/21.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ViewController: UIViewController {
    
    let realm = try! Realm()
    
    var orderArray: [OrderModel] = []
    var orders: Results<Order>!
    
    var orderLogger = OrderLoggerManager()
            
    @IBOutlet var orderLog: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderLog.dataSource = self
        orderLog.delegate = self
        searchBar.delegate = self
                
        // Loading Orders
        loadOrders()
        
        self.orderLog.keyboardDismissMode = .onDrag
        
                
        orderLog.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.loadOrders()
        }
   }
    
    func loadOrders() {
        
        orders = realm.objects(Order.self).sorted(byKeyPath: "dateTime", ascending: false)
        orderLog.reloadData()
        
    }
    
//MARK: - Unwind Segue from order logging form
    @IBAction func unwindToOrderLog(segue: UIStoryboardSegue) {
        //Nothing goes here
    }
}

//MARK: - TableView Delegate and DataSource Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell") as! SwipeTableViewCell
        
        cell.delegate = self
        
        let order = orders[indexPath.row]
        cell.textLabel?.text = order.dateTime
        
        
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
            
            destination.dateTime = order.dateTime
            destination.notes = order.notes
            if let images = orderLogger.loadImages(fileNames: order.photos){
                destination.images = images
            }
            
        }
    
    }

}

//MARK: - SwipeTableViewCell Delegate methods
extension ViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // Handle action by updating model with deletion
                
                if let orderToDelete = self.orders?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.orderLogger.removeImage(imageNames: orderToDelete.photos)
                            self.realm.delete(orderToDelete)
                        }
                    } catch {
                        print("Error deleting order, \(error)")
                    }
                    
                    self.orderLog.reloadData()
                }
            }

            return [deleteAction]

    }

}

//MARK: - SearchBar Delegate Methods
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        orders = orders?.filter("dateTime CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateTime", ascending: true)
        orderLog.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadOrders()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
