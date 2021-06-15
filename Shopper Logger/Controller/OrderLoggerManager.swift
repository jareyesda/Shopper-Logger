//
//  OrderLoggerManager.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/15/21.
//

import UIKit
import CoreData

struct OrderLoggerManager {
        
    //MARK: - Save Order Function
    func saveOrder(dateTime: String, orderNotes: String, images: Data?) {
                
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }

          // 1) Declaring context
          let managedContext =
            appDelegate.persistentContainer.viewContext

          // 2) Defining entity
          let entity =
            NSEntityDescription.entity(forEntityName: "Order",
                                       in: managedContext)!

          let order = NSManagedObject(entity: entity,
                                       insertInto: managedContext)

          // 3) Setting values to be saved to entity
        order.setValue(dateTime, forKeyPath: "dateTime")
        order.setValue(orderNotes, forKey: "notes")
        if let safeImages = images {
            order.setValue(safeImages, forKey: "photos")
        }

          // 4) Saving the data
          do {
            try managedContext.save()
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
          }
            
    }
    
    //MARK: - Load Orders Function
    func loadItems() -> [NSManagedObject] {
        
        var orders = [NSManagedObject]()
        
    //1
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return orders
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
        
        return orders
            
    }
    
}
