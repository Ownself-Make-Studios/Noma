//
//  MultipleCountdownWidgetEntryView.swift
//  countie
//
//  Created by Nabil Ridhwan on 25/6/25.
//


import WidgetKit
import SwiftUI
import SwiftData

struct MultipleCountdownWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
        
    }
}