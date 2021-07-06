//
//  PhotosAttributeMigration.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 7/5/21.
//

import Foundation
import CoreData

class PhotosAttributeMigration: NSEntityMigrationPolicy {
    
    @objc func changeData(forData: Data) -> String {
        var string = ""
        if let path = String(data: forData, encoding: .utf8) {
            string = path
        }
        
        return string
//        return String(data: forData, encoding: .utf8)!
    }
}
