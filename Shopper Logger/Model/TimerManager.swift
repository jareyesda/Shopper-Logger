//
//  TimerManager.swift
//  Shopper Logger
//
//  Created by Juan Reyes on 6/30/21.
//

import Foundation

struct TimerManager {
    
    //MARK: - Time formatting functions
    func formatHMS(_ number: Int) -> String {
        var retVal = ""
        if (number < 10) {
            retVal = "0\(number)"
        } else {
            retVal = "\(number)"
        }
        return retVal
    }
    
    func formatHour(_ hour: Int) -> Int {
        var retVal = hour
        if hour > 12 {
            retVal -= 12
        }
        return retVal
    }
}
