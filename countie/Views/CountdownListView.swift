//
//  CountdownListView.swift
//  countie
//
//  Created by Nabil Ridhwan on 17/5/25.
//

import SwiftUI

struct CountdownListView: View {
    var countdowns: [CountdownItem]
    @State private var searchText: String = ""
    var onDelete: ((IndexSet) -> Void)? = nil

    @State private var selectedCountdown: CountdownItem? = nil

    var filteredCountdowns: [CountdownItem] {
        if searchText.isEmpty {
            return countdowns
        } else {
            return countdowns.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var firstCountdown: CountdownItem? {
        filteredCountdowns.first
    }

    var restOfTheCountdowns: [CountdownItem] {
        Array(filteredCountdowns.dropFirst())
    }

    var body: some View {
        NavigationStack {
            List {

                if let fcd = firstCountdown {

                    Section {
                        //                    Text("Look forward to...")
                        //                        .opacity(0.5)
                        //                        .listRowBackground(Color.clear)
                        //                        .listRowInsets(
                        //                            .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                        //                        )
                        //                        .listRowSeparator(.hidden)

                        ZStack {

                            NavigationLink(
                                destination: CountdownDetailView(countdown: fcd)

                            ) {
                                EmptyView()
                            }

                            RoundedRectangle(cornerRadius: 24)

                                .fill(
                                    LinearGradient(
                                        gradient:
                                            Gradient(
                                                colors: [
                                                    Color(
                                                        vibrantDominantColorOf:
                                                            fcd.emoji ?? "🎉"
                                                    ) ?? .accentColor,
                                                    Color
                                                        .backgroundThemeRespectable
                                                        .mix(
                                                            with: .white,
                                                            by: 0.16
                                                        ),
                                                ]
                                            ),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .stroke(
                                    Color.primary.opacity(0.1),
                                    lineWidth: 1.5
                                )
                                //                            .strokeBorder(style: .init(lineWidth: 1.3))

                                .ignoresSafeArea(.all)
                                .frame(
                                    width: .infinity,
                                    height: 230
                                )

                            VStack {
                                CircularEmojiView(
                                    emoji: fcd.emoji
                                        ?? "🎉",
                                    progress: Float(
                                        fcd.progress
                                    ),
                                    width: 60,
                                    brightness: 0.3,
                                    lineWidth: 4,
                                    gap: 10,
                                    emojiSize: 24
                                )

                                .padding()

                                Text(
                                    fcd.name
                                )
                                .bold()
                                .padding(.vertical, 3)

                                VStack(spacing: 8) {

                                    Text(
                                        filteredCountdowns.first?
                                            .formattedDateString
                                            ?? "No date set"
                                    )
                                    .font(.subheadline)
                                    .opacity(0.5)

                                    Text(
                                        filteredCountdowns.first?
                                            .timeRemainingString
                                            ?? "No time remaining"
                                    )
                                    .font(.caption)
                                    .opacity(0.5)

                                }

                            }
                        }
                    }
                    .listStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )

                }

                //                Section("Pinned"){
                //                    ScrollView(.horizontal, showsIndicators: false){
                //
                //                        LazyHStack{
                //                            ForEach(filteredCountdowns, id: \..id) { countdown in
                //                                NavigationLink(destination: AddCountdownView(countdownToEdit: countdown)) {
                //                                    CountdownListItemView(item: countdown)
                //                                        .frame(maxWidth: 200)
                //
                //                                        .padding()
                //
                //                                }
                //                                .buttonStyle(.plain)
                //                                 .contextMenu {
                //                                            Button("Pin") {
                //                                                handlePin(countdown.id)
                //                                            }
                //                                        }
                //
                //                            }
                ////                            .onDelete(perform: onDelete)
                //                        }
                //                    }
                //                }

                ForEach(restOfTheCountdowns, id: \.id) { countdown in
                    NavigationLink(
                        destination:
                            //                            AddCountdownView(countdownToEdit: countdown)
                            CountdownDetailView(countdown: countdown),
                    ) {
                        CountdownListItemView(item: countdown)
                            .padding(.vertical, 6)

                    }
                    .contextMenu {
                        Button("Pin") {
                            handlePin(countdown.id)
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
            .searchable(text: $searchText, prompt: "Search countdowns")
        }
    }

    func handlePin(_ id: UUID) {
        // Pin or unpin logic goes here
        print(id.uuidString)
    }
}

#Preview {
    CountdownListView(
        countdowns: [
            CountdownItem.SamplePastTimer,
            CountdownItem.Graduation,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
        ]
    )
}
