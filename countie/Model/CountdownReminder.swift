//
//  CountdownReminder.swift
//  countie
//
//  Created by Nabil Ridhwan on 12/11/24.
//

import Foundation

struct CountdownReminder {
    var label: String
    var date: Date
    var valueInSeconds: Int {
        Int(date.timeIntervalSince(Date.now))
    }
    
    static let FIVE_MIN = CountdownReminder(label: "5 minutes", date: Date.now.addingTimeInterval(5*60))
    static let TEN_MIN = CountdownReminder(label: "10 minutes", date: Date.now.addingTimeInterval(10*60))
    static let FIFTEEN_MIN = CountdownReminder(label: "15 minutes", date: Date.now.addingTimeInterval(15*60))
    static let THIRTY_MIN = CountdownReminder(label: "30 minutes", date: Date.now.addingTimeInterval(30*60))
    static let ONE_HOUR = CountdownReminder(label: "1 hour", date: Date.now.addingTimeInterval(60*60))
    static let TWO_HOUR = CountdownReminder(label: "2 hours", date: Date.now.addingTimeInterval(120*60))
    static let ONE_DAY = CountdownReminder(label: "1 day", date: Date.now.addingTimeInterval(24*60*60))
    static let TWO_DAY = CountdownReminder(label: "2 days", date: Date.now.addingTimeInterval(48*60*60))
}
