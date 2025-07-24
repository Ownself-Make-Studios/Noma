//
//  CountdownDetailView.swift
//  countie
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import SwiftUI

struct CountdownDetailView: View {
    var countdown: CountdownItem
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

                    Text(countdown.timeRemainingString)
                        .font(.subheadline)
                        .opacity(0.5)
                        .padding(.vertical, 10)

                    
                    NavigationLink(
                        destination:
                            AddCountdownView(countdownToEdit: countdown)
                    ){
//                        Button(action: {}) {}
//                    .padding(.top, 50)
                        
                        
                        Label(
                            "Edit Countdown",
                            systemImage: "square.and.pencil"
                        )
                        .font(.caption)
                        .padding(14)
                        .background(
                            Color(vibrantDominantColorOf: countdown.emoji ?? "")?.opacity(0.7)
                                ?? .accentColor
                                .mix(with: Color.black, by: 0.2)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(.infinity)
                    
                    }
                    
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
