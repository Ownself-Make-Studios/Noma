//
//  CountdownListItemView.swift
//  countie
//
//  Created by Nabil Ridhwan on 29/10/24.
//

import SwiftUI
import Combine

struct CountdownListItemView: View {
    
    @State var item: CountdownItem
    
    @State private var currentTime = Date()
    @State private var timerCancellable: Cancellable?
    
    var countdownHasEnded: Bool {
        item.date < currentTime
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            
            
            Text("\(item.emoji ?? "") \(item.name)")
                .bold()
            
            Text(item.formattedDateString)
                .font(.caption)
                .opacity(0.5)
            
            Text(
                countdownHasEnded ?
                item.timeRemainingPassedString :
                item.timeRemainingString
            )
                .font(.caption2)
                .opacity(0.5)
            HStack(spacing: 6) {
                
                LinearProgressView(value: item.progress, shape: Capsule())
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .frame(height: 4)
                
                
                Text("\(item.progressString)%")
                    .font(.caption2)
                    .opacity(0.4)
                
            }
            .padding(.top, 4)
        }
        .opacity(countdownHasEnded ? 0.5 : 1.0)
        .onAppear{
            
            if(!countdownHasEnded){
                // Start the timer when the view appears
                timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { input in
                        currentTime = input
                    }
            }else{
                 // Start the timer when the view appears
                timerCancellable = Timer.publish(every: 1 * 60 * 60, on: .main, in: .common)
                    .autoconnect()
                    .sink { input in
                        currentTime = input
                    }
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
        item: .SampleFutureTimer
    )
}
