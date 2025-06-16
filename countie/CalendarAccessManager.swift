//
//  CalendarAccessManager.swift
//  countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit

struct CalendarAccessManager: Observable {
    static var store = EKEventStore()
    private var hasAccess = false
    
    static func requestPermission() {
        store.requestFullAccessToEvents { granted, error in
            if granted {
                print("[CALENDARACCESSMANAGER] Access granted")
            } else {
                print("[CALENDARACCESSMANAGER] Access denied")
            }
        }
    }
    
    static func event(with identifier: String) -> EKEvent? {
        return store.event(withIdentifier: identifier)
    }
}
