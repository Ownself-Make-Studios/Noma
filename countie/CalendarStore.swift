//
//  CalendarStore.swift
//  countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit

struct CalendarStore: Observable {
    static var store = EKEventStore();
    private var hasAccess = false;
    
    static func requestPermission(){
        store.requestFullAccessToEvents {
            granted, error in
            
            if(granted){
                print("[CALENDARSTORE] Access granted")
            }else{
                print("[CALENDARSTORE] Access denied")
            }
                
        }
        
    }
}
    

