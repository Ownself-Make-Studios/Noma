//
//  CountdownWidgetEntryView.swift
//  countie
//
//  Created by Nabil Ridhwan on 25/10/24.
//

import SwiftUI
import SwiftData

struct CountdownWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack{
            
            if let countdownItem = entry.countdownItem {
                Text(countdownItem.emoji ?? "")
                    .padding(4)
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    
                    Text(countdownItem.name)
                        .font(.headline)
                    
                    Text(countdownItem.timeRemainingString)
                        .font(.caption)
                }
                
            }else{
                Text("No countdowns :(")
            }
        }
    }
}
