//
//  OrderLoggerManager.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/15/21.
//

import UIKit
import CoreData
import RealmSwift

struct OrderLoggerManager {
    
    let realm = try! Realm()
        
    //MARK: - Save Order Function
    func save(order: Order) {
                
        do {
            try realm.write {
                realm.add(order)
            }
        } catch {
            print("Error saving context: \(error)")
        }

    }
    
    //MARK: - Save image in documents directory function
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    func saveImage(image: UIImage) -> String? {
        let fileName = NSUUID().uuidString + ".png"
        let fileURL = getDocumentsURL().appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName
        }
        print("Error saving image")
        return nil
    }
    
    func loadImages(fileNames: List<String>) -> [UIImage]? {
        
        var retImages = [UIImage]()
        for fileName in fileNames {
            let fileURL = getDocumentsURL().appendingPathComponent(fileName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                retImages.append(UIImage(data: imageData)!)
            } catch {
                print("Error loading image : \(error)")
            }
        }
        
        return retImages
    }
    
    func removeImage(imageNames: List<String>) {
        for imageName in imageNames {
            let fileURL = getDocumentsURL().appendingPathComponent(imageName)
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print(error)
            }
        }
    }
    
}
