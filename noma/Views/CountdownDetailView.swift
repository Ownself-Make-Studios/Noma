//
//  CountdownDetailView.swift
//  noma
//
//  Created by Nabil Ridhwan on 24/7/25.
//

import SwiftUI

struct CountdownDetailView: View {
    @EnvironmentObject var store: CountdownStore

    @AppStorage("showProgress") private var showProgress: Bool = true

    @Environment(\.dismiss) private var dismiss
    var countdown: CountdownItem
    @State private var isConfirmDeletePresented: Bool = false
    var onClose: (() -> Void)? = nil

    @State private var now: Date = Date()
    @State private var timer: Timer? = nil

    func handleDelete() {
        store.deleteCountdown(countdown)
    }

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
                    showProgress: true,
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
                        .multilineTextAlignment(.center)

                    Text(countdown.formattedDateTimeString)
                        .font(.subheadline)
                        .opacity(0.5)
                        .multilineTextAlignment(.center)

                    // Segregated countdown display
                    let components = Calendar.current.dateComponents(
                        [.day, .hour, .minute, .second],
                        from: now,
                        to: countdown.date
                    )
                    let values = [
                        max(0, components.day ?? 0),
                        max(0, components.hour ?? 0),
                        max(0, components.minute ?? 0),
                        max(0, components.second ?? 0),
                    ]
                    let units = ["days", "hours", "minutes", "seconds"]

                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            ForEach(0..<values.count, id: \.self) { idx in
                                VStack {
                                    Text(
                                        "\(values[idx] < 10 ? "0" : "")\(values[idx])"
                                    )
                                    .font(.title2.monospacedDigit())
                                    .bold()
                                    .frame(minWidth: 36, minHeight: 36)
                                    .padding(3)
                                    .padding(.horizontal, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                Color.primary.opacity(0.2),
                                                lineWidth: 1
                                            )
                                            .background(
                                                RoundedRectangle(
                                                    cornerRadius: 8
                                                ).fill(
                                                    Color(.systemBackground)
                                                        .opacity(0.7)
                                                )
                                            )
                                    )
                                    
                                    Text(units[idx])
                                     .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(minWidth: 36)
                                }
                            }
                        }
                    }
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
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                _ in
                now = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .toolbar {

            ToolbarItem {
                Button(action: {
                    //                                        handleDelete()
                    isConfirmDeletePresented = true
                }) {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.red)
                }
                .confirmationDialog(
                    "Are you sure you want to delete this countdown?",
                    isPresented: $isConfirmDeletePresented,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        print("Deleting countdown: \(countdown.name)")
                        // Remove from the list or perform deletion in your data model

                        handleDelete()
                        onClose?()
                        dismiss()
                    }
                }
            }

            countdown.date < Date()
                ? nil
                : ToolbarItem {
                    NavigationLink(
                        destination: AddCountdownView(
                            countdownToEdit: countdown
                        )
                    ) {
                        Label(
                            "Edit Countdown",
                            systemImage: "square.and.pencil"
                        )
                        .labelStyle(.titleAndIcon)
                    }
                }
        }

    }
}

#Preview {
    CountdownDetailView(
        countdown: .Graduation
    )
}
