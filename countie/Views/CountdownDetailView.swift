//
//  CountdownDetailView.swift
//  countie
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import SwiftUI

struct CountdownDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var countdown: CountdownItem
    var onClose: (() -> Void)? = nil
    
    @State private var now: Date = Date()
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {

            Rectangle()
                .fill(
                    LinearGradient(
                        gradient:
                            Gradient(
                                colors: [
                                    Color(
                                        vibrantDominantColorOf: countdown.emoji
                                            ?? ""
                                    ) ?? .accentColor,
                                    Color.backgroundThemeRespectable.mix(
                                        with: .white,
                                        by: 0.16
                                    ),
                                ]
                            ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(.all)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            VStack {

                CircularEmojiView(
                    emoji: countdown.emoji ?? "",
                    progress: Float(countdown.progress),
                    width: 200,
                    brightness: 0.3,
                    lineWidth: 14,
                    gap: 40,
                    emojiSize: 60
                )
                .padding(.bottom, 40)

                VStack {
                    Text(countdown.name)
                        .font(.title)
                        .bold()

                    Text(countdown.formattedDateString)
                        .font(.subheadline)
                        .opacity(0.5)

                    Text(countdown.getTimeRemainingString(
                        since: now,
                        units: [.day, .hour, .minute, .second],
                        unitsStyle: .full
                        
                    ))
                        .font(.subheadline)
                        .opacity(0.5)
                        .padding(.vertical, 10)
                    
                }
            }
            .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                now = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .toolbar{
            ToolbarItem{
                NavigationLink(destination: AddCountdownView(countdownToEdit: countdown)){
                    Label("Edit Countdown", systemImage: "square.and.pencil")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
}

#Preview {
    CountdownDetailView(
        countdown: .SampleFutureTimer
    )
}
