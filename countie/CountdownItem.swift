//
//  Item.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import Foundation
import SwiftData

@Model
final class CountdownItem {
    var name: String
    var date: Date
    
    /**
     Calculates days left from now until date. If the days left is below 0, return 0
     https://sarunw.com/posts/getting-number-of-days-between-two-dates/#number-of-24-hours-days%2C-not-including-a-start-date
     */
    var _daysLeft: Int {
        let numberOfDays = Calendar.autoupdatingCurrent.dateComponents([.year,.month,.day,.hour,.minute], from: Date.now, to: self.date)
        
        return numberOfDays.day!
    }
    
    // https://stackoverflow.com/a/72320725
    var daysLeft: String {
        
        if(_daysLeft < 1){
            return "Less than a day"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        dateComponentsFormatter.unitsStyle = .full
        var dateRemainingText = dateComponentsFormatter.string(from: Date.now, to: date)!
        if dateRemainingText.hasPrefix("-") {
            dateRemainingText = "\(dateRemainingText.dropFirst()) ago"
        } else {
            dateRemainingText = "in \(dateRemainingText)"
        }
        
        return dateRemainingText
    }
    
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }
}
