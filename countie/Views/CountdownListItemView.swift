//
//  CountdownListItemView.swift
//  countie
//
//  Created by Nabil Ridhwan on 29/10/24.
//

import Combine
import SwiftUI

struct CountdownListItemView: View {

    @AppStorage("showProgress") private var showProgress: Bool = true
    @State var item: CountdownItem

    @State private var currentTime = Date()
    @State private var timerCancellable: Cancellable?

    var countdownHasEnded: Bool {
        item.date < currentTime
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack {
                
                
                CircularEmojiView(emoji: item.emoji ?? "", progress: Float(showProgress ? item.progress : 0))
                    .padding(.trailing, 6)

                VStack(alignment: .leading) {
                    

                    Text("\(item.name)")
//                        .font(.caption)
                        .font(.system(size: 15))
                        .bold()

                    Text(item.formattedDateString)
                        .font(.caption)
                        .opacity(0.5)

//                    showProgress
//                        ? (HStack(spacing: 6) {
//
//                            LinearProgressView(
//                                value: item.progress,
//                                shape: Capsule()
//                            )
//                            .tint(Color(vibrantDominantColorOf: item.emoji ?? "") ?? .gray.opacity(0.3))
//                            .frame(height: 4)
//
//                            Text("\(item.progressString)%")
//                                .font(.caption2)
//                                .opacity(0.4)
//
//                        }
//                        .padding(.top, 4)) : nil

                }
                
                Spacer()

                Text(
                    countdownHasEnded
                        ? item.getTimeRemainingPassedFn(since: currentTime)
                        : item.getTimeRemainingFn(since: currentTime)
                )
                .font(.caption2)
                .opacity(0.5)

            }
        }
        .opacity(countdownHasEnded ? 0.5 : 1.0)
        .onAppear {
            if !countdownHasEnded {
                // Start the timer when the view appears
                timerCancellable = Timer.publish(
                    every: 1,
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .sink { input in
                    currentTime = input
                }
            } else {
                // Start the timer when the view appears
                // to update the view even if the countdown has ended
                timerCancellable = Timer.publish(
                    every: 1 * 60 * 60,
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .sink { input in
                    currentTime = input
                }
            }
        }
        .onDisappear {
//             Cancel the timer when the view disappears to prevent memory leaks
            timerCancellable?.cancel()
        }
    }
}

#Preview {
    CountdownListItemView(
        item: .Graduation
    )
}
