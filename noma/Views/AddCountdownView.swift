//
//  AddCountdownView.swift
//  noma
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import EventKit
import MCEmojiPicker
import SwiftUI
import WidgetKit

extension UIKeyboardType {
    static let emoji = UIKeyboardType(rawValue: 124)
}

struct AddCountdownView: View {
    @EnvironmentObject var store: CountdownStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    var onAdd: (() -> Void)? = nil

    // Optional countdown to edit
    var countdownToEdit: CountdownItem? = nil

    @State var emoji: String = ""
    @FocusState private var emojiFieldFocused: Bool
    @State var name: String = ""
    @State var countdownDate: Date = Calendar.current.startOfDay(for: Date.now)
        .addingTimeInterval(7 * 24 * 60 * 60)
    //    @State var countSinceDate: Date = Calendar.current.startOfDay(for: Date.now)
    @State var countSinceDate: Date = Date.now
    @State var hasTime: Bool = true
    @State var updateCountdownWhenEventChanges: Bool = false
    @State var reminders: [CountdownReminder] = []
    @State private var selectedReminder: CountdownReminder = .FIVE_MIN

    @State private var showEmojiPicker: Bool = false
    @State private var linkedEvent: EKEvent? = nil

    var isSubmitDisabled: Bool {
        name.isEmpty && emoji.isEmpty
    }

    init(countdownToEdit: CountdownItem? = nil, onAdd: (() -> Void)? = nil) {
        self.countdownToEdit = countdownToEdit
        self.onAdd = onAdd
    }

    init(
        name: String = "",
        countdownDate: Date = Calendar.current.startOfDay(for: Date.now),
        hasTime: Bool = false,
        linkedEvent: EKEvent? = nil,
        onAdd: (() -> Void)? = nil
    ) {
        _name = .init(initialValue: name)
        _countdownDate = .init(initialValue: countdownDate)
        _hasTime = .init(initialValue: hasTime)
        _linkedEvent = .init(initialValue: linkedEvent)
        self.onAdd = onAdd
    }

    func handleSaveItem() {
        if let editing = countdownToEdit {
            // Edit existing
            editing.emoji = emoji
            editing.name = name
            editing.includeTime = hasTime
            editing.date = countdownDate
            editing.countSince = countSinceDate

            // if includeTime is false, set the time to start of day
            if !hasTime {
                editing.date = Calendar.current.startOfDay(for: countdownDate)
                editing.countSince = Calendar.current.startOfDay(
                    for: countSinceDate
                )
            }

            if let event = linkedEvent {
                editing.calendarEventIdentifier = event.eventIdentifier
            } else {
                editing.calendarEventIdentifier = nil
            }

            try? modelContext.save()
        } else {
            // Add new
            let item: CountdownItem = CountdownItem(
                emoji: emoji,
                name: name,
                includeTime: hasTime,
                date: countdownDate
            )
            item.countSince = countSinceDate

            // if includeTime is false, set the time to start of day

            if !hasTime {
                item.date = Calendar.current.startOfDay(for: countdownDate)
                item.countSince = Calendar.current.startOfDay(
                    for: countSinceDate
                )
            }

            if let event = linkedEvent {
                item.calendarEventIdentifier = event.eventIdentifier
            }

            modelContext.insert(item)
            try? modelContext.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
        store.fetchCountdowns()
        dismiss()
        onAdd?()
    }

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120)
                        .overlay(
                            Group {
                                if emoji.isEmpty {
                                    Image(systemName: "face.dashed")
                                        .resizable()
                                        .frame(width: 42, height: 42)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(emoji)
                                        .font(.system(size: 42))
                                }
                            }
                        )
                        .onTapGesture {
                            withAnimation {
                                print("Show emoji picker")
                                emojiFieldFocused = true
                            }
                        }
                    Spacer()
                }
                .listRowBackground(Color.clear)

                Section("Countdown Name") {
                    TextField("Graduation, Anniversary, etc.", text: $name)
                }

                if let event = linkedEvent {
                    Section("Calendar Event") {
                        HStack {
                            Circle()
                                .fill(Color(event.calendar.cgColor))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.startDate.formatted())
                                    .font(.subheadline)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {

                            Button("Unlink Event") {
                                linkedEvent = nil
                            }

                            Text(
                                "Unlinking the event will remove the link to the calendar event, and the countdown will not update if the event changes."
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                        }

                        //                        Toggle(
                        //                            "Update countdown when event changes",
                        //                            isOn: $updateCountdownWhenEventChanges
                        //                        )
                        //                        .disabled(true)  // Disable this for now, as we don't have the logic implemented yet

                    }
                }

                Section("Countdown Settings") {
                    Toggle("Include Time of day", isOn: $hasTime)
                        .disabled(linkedEvent != nil)

                    DatePicker(
                        "Countdown Target Date\(hasTime ? " & Time" : "")",
                        selection: $countdownDate,
                        in: Date.now...,
                        displayedComponents: hasTime
                            ? [.date, .hourAndMinute] : [.date]
                    )
                    .disabled(linkedEvent != nil)

                    VStack(alignment: .leading, spacing: 10) {

                        DatePicker(
                            "Countdown Start Date\(hasTime ? " & Time" : "")",
                            selection: $countSinceDate,
                            in: ...countdownDate,
                            displayedComponents: hasTime
                                ? [.date, .hourAndMinute] : [.date]
                        )

                        Text(
                            "Progress starts from this date."
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    }
                }

                //                Section("Reminders") {
                //                    Button("Add Reminder"){
                //
                //                    }
                //                }

                // Keyboard for the emoji picker!
                TextField("Emoji", text: $emoji)
                    .keyboardType(.emoji!)
                    .focused($emojiFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .onChange(of: emoji) { _, newVal in
                        if !newVal.isEmpty {

                            emoji = newVal.last.map { String($0) } ?? ""
                            withAnimation {
                                emojiFieldFocused = false  // Close keyboard when emoji selected
                            }
                        }
                    }
                    .listRowBackground(Color.clear)

            }
            .navigationTitle(
                countdownToEdit == nil ? "New Countdown" : "Edit Countdown"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(countdownToEdit == nil ? "Add" : "Save") {
                    handleSaveItem()
                }.disabled(isSubmitDisabled)
            }

        }
        .onAppear {
            if let editing = countdownToEdit {
                emoji = editing.emoji ?? ""
                name = editing.name
                hasTime = editing.includeTime
                countdownDate = editing.date
                countSinceDate = editing.countSince

                if let eventIdentifier = editing.calendarEventIdentifier {

                    linkedEvent = CalendarAccessManager.event(
                        with: eventIdentifier
                    )
                }
            }
        }
        .onChange(of: hasTime) { _, newVal in
            if !newVal {
                let dateWithoutTime = Calendar.current.startOfDay(
                    for: countdownDate
                )
                countdownDate = dateWithoutTime
            }
        }
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
}
