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
        HStack(spacing: 6) {
            if let countdownItem = entry.countdownItem {
                Text(countdownItem.emoji ?? "")
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(countdownItem.name)
                        .font(.system(size: 16))
                        .lineLimit(2)
                    
                    Text(countdownItem.timeRemainingString)
                        .font(.caption)
                }
                
            }else{
                Text("No countdowns to display")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
