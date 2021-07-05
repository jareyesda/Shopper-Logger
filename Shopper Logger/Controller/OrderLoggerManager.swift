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
    
    //MARK: - Save Function for ALL orders after deleting one object
    func saveOrders(tableViewToReload: UITableView) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableViewToReload.reloadData()
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
    
    //MARK: - Convert NSManagedObject to a OrderModel array
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
    
    //MARK: - Binary Data -> Image converter
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
    
    //MARK: - Image -> Binary data converter
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
    
    //MARK: - Save image in documents directory function
    func saveImages(image: UIImage) -> String {
        
        let imageData = NSData(data: image.pngData()!)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs = paths[0] as String
        let uuid = NSUUID().uuidString + ".png"
        let fullPath = docs.appending(uuid)
        _ = imageData.write(toFile: fullPath, atomically: true)
        return uuid
        
    }
    
    func getImages(imageNames: [String]) -> [UIImage] {
        
        var savedImages = [UIImage]()
        for imageName in imageNames {
            if let imagePath = getFilePath(fileName: imageName) {
                savedImages.append(UIImage(systemName: imagePath)!)
            }
        }
        
        return savedImages
        
    }
    
    func getFilePath(fileName: String) -> String? {
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        var filePath: String?
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0] as NSString
            filePath = dirPath.appendingPathComponent(fileName)
        }
        else {
            filePath = nil
        }
        
        return filePath
        
    }
    
    //MARK: - Load Images from File Directory
    func getImage(imageNames: [String]) -> [UIImage] {
        
        var savedImages = [UIImage]()
        
        for imageName in imageNames {
            if let imagePath = getFilePath(fileName: imageName) {
                savedImages.append(UIImage(contentsOfFile: imagePath)!)
            }
        }
        
        return savedImages
        
    }
    
}
