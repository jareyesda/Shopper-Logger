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
    
    //MARK: - <#Section Heading#>
    
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
    
    func coreToOrderArray(_ coreOrderArray: [NSManagedObject]) -> [OrderModel] {
        
        var orders = [OrderModel]()
//        let defaultImage: [UIImage]

        for coreOrder in coreOrderArray {
            let orderDateTime = coreOrder.value(forKey: "dateTime") as? String
            let orderNotes = coreOrder.value(forKey: "notes") as? String
            let orderPhotos = (imagesFromCoreData(object: coreOrder.value(forKey: "photos") as? Data))!

            orders.append(OrderModel(dateTime: orderDateTime, notes: orderNotes, photos: orderPhotos))

        }

        return orders
    }
    
    //MARK: - Delete Order Function
    func deleteOrder(orderToDelete: NSManagedObject) {
        
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


          // 4) Deleting the data
            managedContext.delete(order)
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
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
    
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
    
}
