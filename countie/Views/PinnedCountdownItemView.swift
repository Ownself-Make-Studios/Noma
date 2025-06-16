//
//  PinnedCountdownItemView.swift
//  countie
//
//  Created by Nabil Ridhwan on 16/6/25.
//

import SwiftUI
import Combine

struct PinnedCountdownItemView: View {
    @ObservedObject var item: CountdownItem
    
    @State private var currentTime = Date()
    @State private var timerCancellable: Cancellable?
    
    let cardSize = CGFloat(120)
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.emoji ?? "")
                    .font(.system(size: 32))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(item.name)
                    .bold()
                    .font(.system(size: 14))
                    .lineLimit(2)

                Text(item.formattedDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(item.timeRemainingString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(minWidth: cardSize,
                   maxWidth: cardSize,
                   minHeight: cardSize,
                   maxHeight: cardSize)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .opacity(item.date > currentTime ? 1 : 0.5)
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
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 200)) {
    PinnedCountdownItemView(
        item: .SampleFutureTimer
    )
}
