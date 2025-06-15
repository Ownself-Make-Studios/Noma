//
//  Item.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import Foundation
import SwiftData
import AppIntents

@Model
class CountdownItem: ObservableObject{
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var emoji: String?
    @Attribute var name: String
    @Attribute var includeTime: Bool = false
    @Attribute var date: Date
    
    @Attribute var calendarEventIdentifier: String?

    init(emoji: String?, name: String, includeTime: Bool, date: Date, calendarEventIdentifier: String? = nil) {
        self.emoji = emoji
        self.name = name
        self.includeTime = includeTime
        self.date = date
        self.calendarEventIdentifier = calendarEventIdentifier
    }
    
    /**
     Calculates the date difference between two dates (used by functions below)
     */
    var dateDifference: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents(
            [.year,.month,.day,.hour,.minute],
            from: Date.now,
            to: self.date
        )
    }
    
    // Computed Property for days left
    var _daysLeft: Int {
        return dateDifference.day!
    }
    
    // Computed Property for hours left
    var _hoursLeft: Int {
        return dateDifference.hour!
    }
    
    /**
     Returns the time remaining as a String
     https://stackoverflow.com/a/72320725
     */
    var timeRemainingString: String {
        if (_daysLeft == 0 && _hoursLeft == 0){
            return "Now"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year, .month, .day, .hour]
        dateComponentsFormatter.unitsStyle = .full
        var dateRemainingText = dateComponentsFormatter.string(from: Date.now, to: date)!
        
        // Time that has passed will have a minus prefix e.g. -1 day ago
        if dateRemainingText.hasPrefix("-") {
            dateRemainingText = "\(dateRemainingText.dropFirst()) ago"
        } else {
            dateRemainingText = "\(dateRemainingText)"
        }
        
        return dateRemainingText
    }
    
    /**
     Formatted date string
     */
    var formattedDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(emoji: "😊", name: "Demo Item (Future)", includeTime: true, date: Date.distantFuture)
    
    public static var SamplePastTimer = CountdownItem(emoji: nil, name: "Demo Item (Past)", includeTime: true, date: Date.now.addingTimeInterval(-86400))
}
