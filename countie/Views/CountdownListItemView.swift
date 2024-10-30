//
//  CountdownListItemView.swift
//  countie
//
//  Created by Nabil Ridhwan on 29/10/24.
//

import SwiftUI
import Combine

struct CountdownListItemView: View {
    
    @ObservedObject var item: CountdownItem
    
    @State private var currentTime = Date()
    @State private var timerCancellable: Cancellable?
    
    func timeRemaining(until endDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentTime, to: endDate)
        
        var parts: [String] = []
        
        if let year = components.year, year > 0 {
            parts.append("\(year) year\(year > 1 ? "s" : "")")
        }
        if let month = components.month, month > 0 {
            parts.append("\(month) month\(month > 1 ? "s" : "")")
        }
        if let day = components.day, day > 0 {
            parts.append("\(day) day\(day > 1 ? "s" : "")")
        }
        if let hour = components.hour, hour > 0 {
            parts.append("\(hour) hour\(hour > 1 ? "s" : "")")
        }
        if let minute = components.minute, minute > 0 {
            parts.append("\(minute) minute\(minute > 1 ? "s" : "")")
        }
        if let second = components.second, second > 0 {
            parts.append("\(second) second\(second > 1 ? "s" : "")")
        }
        
        return parts.joined(separator: ", ")
    }
    
    
    var body: some View {
        
        let remainingTime = item.date.timeIntervalSince(currentTime)
        
        // Break down the time interval into hours, minutes, seconds
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        
        HStack{
            
            Text(item.emoji ?? "")
                .font(.headline)
                .padding(8)
            
            VStack(alignment: .leading){
                Text(item.name)
                Text(item.formattedDateString)
                    .font(.caption)
                //            Text("\(item.timeRemainingString)")
                //                .font(.caption2)
                
                if item.date > currentTime {
                    Text(timeRemaining(until: item.date))
                        .font(.caption2)
                }else {
                    Text(item.timeRemainingString)
                        .font(.caption2)
                }
            }
        }
        
        .onAppear{
            // Start the timer when the view appears
            
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { input in
                    currentTime = input
                }
        }
        .onDisappear {
            // Cancel the timer when the view disappears to prevent memory leaks
            timerCancellable?.cancel()
        }
    }
}

#Preview {
    CountdownListItemView(
        item: .SamplePastTimer
    )
}
