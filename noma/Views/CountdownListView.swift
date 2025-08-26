//
//  CountdownListView.swift
//  noma
//
//  Created by Nabil Ridhwan on 17/5/25.
//

import SwiftUI

struct CountdownListView: View {
    var countdowns: [CountdownItem]
    var onClose: (() -> Void)? = nil
    @State private var searchText: String = ""
    @EnvironmentObject var modalStore: ModalStore

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
//        Array(filteredCountdowns.dropFirst())
        filteredCountdowns
    }

    // Helper: next 12 months from current date
    var next12Months: [Date] {
        let calendar = Calendar.current
        let now = Date()
        var months: [Date] = []
        for offset in 0..<12 {
            if let month = calendar.date(
                byAdding: .month,
                value: offset,
                to: now
            ) {
                let comps = calendar.dateComponents(
                    [.year, .month],
                    from: month
                )
                if let normalized = calendar.date(from: comps) {
                    months.append(normalized)
                }
            }
        }
        return months
    }

    // Group restOfTheCountdowns by month and year
    var countdownsByMonth: [Date: [CountdownItem]] {
        let calendar = Calendar.current
        return Dictionary(grouping: restOfTheCountdowns) { (item) -> Date in
            let comps = calendar.dateComponents(
                [.year, .month],
                from: item.date
            )
            return calendar.date(from: comps) ?? item.date
        }
    }

    // Months with countdowns outside the next 12 months
    var extraMonths: [Date] {
        let next12 = Set(next12Months)
        let allMonths = Set(countdownsByMonth.keys)
        return allMonths.subtracting(next12).sorted()
    }

    // Formatter for section headers
    var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            List {

//                if let fcd = firstCountdown {
//
//                    Section {
//                        //                    Text("Look forward to...")
//                        //                        .opacity(0.5)
//                        //                        .listRowBackground(Color.clear)
//                        //                        .listRowInsets(
//                        //                            .init(top: 0, leading: 0, bottom: 0, trailing: 0)
//                        //                        )
//                        //                        .listRowSeparator(.hidden)
//
//                        ZStack {
//
//                            // https://stackoverflow.com/a/59832389
//                            NavigationLink(
//                                destination: CountdownDetailView(countdown: fcd)
//
//                            ) {
//                                Rectangle().opacity(0)
//                            }.buttonStyle(.plain)
//
//                            RoundedRectangle(cornerRadius: 24)
//
//                                .fill(
//                                    LinearGradient(
//                                        gradient:
//                                            Gradient(
//                                                colors: [
//                                                    Color(
//                                                        vibrantDominantColorOf:
//                                                            fcd.emoji ?? "🎉"
//                                                    ) ?? .accentColor,
//                                                    Color
//                                                        .backgroundThemeRespectable
//                                                        .mix(
//                                                            with: .white,
//                                                            by: 0.16
//                                                        ),
//                                                ]
//                                            ),
//                                        startPoint: .top,
//                                        endPoint: .bottom
//                                    )
//                                )
//                                .stroke(
//                                    Color.primary.opacity(0.1),
//                                    lineWidth: 1.5
//                                )
//                                //                            .strokeBorder(style: .init(lineWidth: 1.3))
//
//                                .ignoresSafeArea(.all)
//                                .frame(
//                                    width: .infinity,
//                                    height: 230
//                                )
//
//                            VStack {
//                                CircularEmojiView(
//                                    emoji: fcd.emoji
//                                        ?? "🎉",
//                                    progress: Float(
//                                        fcd.progress
//                                    ),
//                                    width: 60,
//                                    brightness: 0.3,
//                                    lineWidth: 4,
//                                    gap: 10,
//                                    emojiSize: 24
//                                )
//
//                                .padding()
//
//                                Text(
//                                    fcd.name
//                                )
//                                .bold()
//                                .padding(.vertical, 3)
//
//                                VStack(spacing: 8) {
//
//                                    Text(
//                                        fcd
//                                            .formattedDateString
//                                    )
//                                    .font(.subheadline)
//                                    .opacity(0.5)
//
//                                    Text(
//                                        fcd
//                                            .timeRemainingString
//                                    )
//                                    .font(.caption)
//                                    .opacity(0.5)
//
//                                }
//
//                            }
//                        }
//                    }
//                    .listStyle(.plain)
//                    .listRowBackground(Color.clear)
//                    .listRowInsets(
//                        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
//                    )
//
//                }

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

                ForEach(Array(countdownsByMonth.keys.sorted()), id: \.self) { month in
                    Section(header: Text(month, formatter: monthYearFormatter))
                    {
                        if let items = countdownsByMonth[month], !items.isEmpty
                        {
                            ForEach(items, id: \.id) { countdown in
                                CountdownListItemView(item: countdown, onTap: {
                                    modalStore.isSelectedCountdown = countdown
                                })
                            }
                        } else {
                            ZStack {

                                // https://stackoverflow.com/a/59832389
                                NavigationLink(
                                    destination: AddCountdownView(
                                        countdownDate: month
                                    )
                                ) {
                                    EmptyView()
                                }

                                HStack {
                                    Spacer()
                                    Label(
                                        "Add countdown",
                                        systemImage: "plus"
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: 60

                                    )
                                    .font(.caption)
                                    .padding(28)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                style: StrokeStyle(
                                                    lineWidth: 1,
                                                    dash: [8]
                                                )
                                            )
                                            .foregroundColor(.primary)
                                    )
                                    Spacer()
                                }
                                .opacity(0.4)
                                .padding(.vertical, 4)
                            }
                            .foregroundStyle(.primary)
                            .listRowBackground(Color.clear)
                            .listRowInsets(
                                .init(
                                    top: 0,
                                    leading: 0,
                                    bottom: 0,
                                    trailing: 0
                                )
                            )
                        }
                    }
                }

                // Iterate over the next 12 months and create a section for each
                //                ForEach(next12Months, id: \.self) { month in
                //                    Section(header: Text(month, formatter: monthYearFormatter))
                //                    {
                //                        if let items = countdownsByMonth[month], !items.isEmpty
                //                        {
                //                            ForEach(items, id: \.id) { countdown in
                //                                NavigationLink(
                //                                    destination:
                //                                        CountdownDetailView(
                //                                            countdown: countdown
                //                                        ),
                //                                ) {
                //                                    CountdownListItemView(item: countdown)
                //                                        .padding(.vertical, 6)
                //                                }
                //                                .contextMenu {
                //                                    Button("Pin") {
                //                                        handlePin(countdown.id)
                //                                    }
                //                                }
                //                            }
                //                            .onDelete(perform: onDelete)
                //                        } else {
                //                            ZStack {
                //
                //                                // https://stackoverflow.com/a/59832389
                //                                NavigationLink(
                //                                    destination: AddCountdownView(
                //                                        countdownDate: month
                //                                    )
                //                                ) {
                //                                    EmptyView()
                //                                }
                //
                //                                HStack {
                //                                    Spacer()
                //                                    Label(
                //                                        "Add countdown",
                //                                        systemImage: "plus"
                //                                    )
                //                                    .frame(
                //                                        maxWidth: .infinity,
                //                                        maxHeight: 60
                //
                //                                    )
                //                                    .font(.caption)
                //                                    .padding(28)
                //                                    .background(
                //                                        RoundedRectangle(cornerRadius: 12)
                //                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                //                                            .foregroundColor(.primary)
                //                                    )
                //                                    Spacer()
                //                                }
                //                                .opacity(0.4)
                //                                .padding(.vertical, 4)
                //                            }
                //                            .foregroundStyle(.primary)
                //                            .listRowBackground(Color.clear)
                //                            .listRowInsets(
                //                                .init(top: 0, leading: 0, bottom: 0, trailing: 0    )
                //                            )
                //                        }
                //                    }
                //                }

                // Add sections for months outside the next 12 months
                //                ForEach(extraMonths, id: \.self) { month in
                //                    Section(header: Text(month, formatter: monthYearFormatter))
                //                    {
                //                        if let items = countdownsByMonth[month], !items.isEmpty
                //                        {
                //                            ForEach(items, id: \.id) { countdown in
                //                                NavigationLink(
                //                                    destination:
                //                                        CountdownDetailView(
                //                                            countdown: countdown
                //                                        ),
                //                                ) {
                //                                    CountdownListItemView(item: countdown)
                //                                        .padding(.vertical, 6)
                //                                }
                //                                .contextMenu {
                //                                    Button("Pin") {
                //                                        handlePin(countdown.id)
                //                                    }
                //                                }
                //                            }
                //                            .onDelete(perform: onDelete)
                //                        } else {
                //                            EmptyView()
                //                        }
                //                    }
                //                }
                //
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
        ],
    )
    .environmentObject(
        CountdownStore(
            context: NomaModelContainer.sharedModelContainer.mainContext
        )
    )
}
