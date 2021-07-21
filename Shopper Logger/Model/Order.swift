//
//  OrderData.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 7/9/21.
//

import Foundation
import RealmSwift

class Order: Object {
    @objc dynamic var dateTime: String = ""
    @objc dynamic var notes: String = ""
    var photos = List<String>()
}
