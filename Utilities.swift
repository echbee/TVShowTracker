//
//  Utilities.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-11.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

/*
 Utility functions
 */

class Utilities {
    
    /*
     Returns the next week dates when called
     */
    static var nextWeekDates: [Date] = {
        var dates = [Date]()
        
        var aDate = Date()
        
        let secondsInADay: TimeInterval = 86_400
        
        let dateFormatter = DateFormatter()
        
        for _ in 1...7 {
            dates.append(aDate)
            aDate = aDate + secondsInADay
        }
        
        return dates
    }()
    
    /*
     Helper function convert ISO8601 formatted date
     */
    static func ISO8601Date(from dateString: String) -> Date? {
        return ISO8601DateFormatter().date(from: dateString)
    }
    
}
