//
//  AddCountdownView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import WidgetKit
import MCEmojiPicker
import EventKit

struct AddCountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Optional countdown to edit
    var countdownToEdit: CountdownItem? = nil
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var countdownDate: Date = Calendar.current.startOfDay(for: Date.now)
    @State var countSinceDate: Date = Calendar.current.startOfDay(for: Date.now)
    @State var hasTime: Bool = false
    @State var reminders: [CountdownReminder] = []
    @State private var selectedReminder: CountdownReminder = .FIVE_MIN
    
    @State private var showEmojiPicker: Bool = false
    @State private var linkedEvent: EKEvent? = nil
    
    var onAdd: (() -> Void)? = nil
    
    var isSubmitDisabled: Bool {
        name.isEmpty && emoji.isEmpty
    }
    
    init(countdownToEdit: CountdownItem? = nil, onAdd: (() -> Void)? = nil) {
        self.countdownToEdit = countdownToEdit
        self.onAdd = onAdd
    }
    
    init(name: String = "",
         countdownDate: Date = Calendar.current.startOfDay(for: Date.now),
         hasTime: Bool = false,
         linkedEvent: EKEvent? = nil,
         onAdd: (() -> Void)? = nil
    ) {
        _name = .init(initialValue: name)
        _countdownDate = .init(initialValue: countdownDate)
        _hasTime = .init(initialValue: hasTime)
        _linkedEvent = .init(initialValue: linkedEvent)
    }
    
    func handleSaveItem() {
        if let editing = countdownToEdit {
            // Edit existing
            editing.emoji = emoji
            editing.name = name
            editing.includeTime = hasTime
            editing.date = countdownDate
            editing.countSince = countSinceDate
            // TODO: Save reminders and color if needed
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
            modelContext.insert(item)
            try? modelContext.save()
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget")
        dismiss()
        onAdd?()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack(spacing: 10){
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Group {
                                if emoji.isEmpty {
                                    Image(systemName: "face.dashed")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(emoji)
                                        .font(.system(size: 24))
                                }
                            }
                        )
                        .onTapGesture {
                            showEmojiPicker = true
                        }
                        .emojiPicker(isPresented: $showEmojiPicker, selectedEmoji: $emoji)
                    
                    TextField("Name of Countdown", text: $name)
                }
                
                if let event = linkedEvent {
                    Section("Calendar Event"){
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
                        
                    }
                }
                
                Section {
                    Toggle("Include time", isOn: $hasTime)
                    DatePicker("Countdown Date\(hasTime ? " & Time" : "")",
                               selection: $countdownDate,
                               in: Date.now...,
                               displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                    DatePicker("Count since",
                               selection: $countSinceDate,
                               displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                }
                Section("Reminders") {
                    ForEach(reminders.sorted(by: { $0.date < $1.date }), id: \.date) { reminder in
                        HStack {
                            Text(reminder.label)
                        }
                    }
                    .onDelete { indexSet in
                        reminders.remove(atOffsets: indexSet)
                    }
                    let availableReminders = [
                        CountdownReminder.FIVE_MIN,
                        CountdownReminder.TEN_MIN,
                        CountdownReminder.FIFTEEN_MIN,
                        CountdownReminder.THIRTY_MIN,
                        CountdownReminder.ONE_HOUR,
                        CountdownReminder.TWO_HOUR,
                        CountdownReminder.ONE_DAY,
                        CountdownReminder.TWO_DAY
                    ].filter { !reminders.contains($0) }
                    if !availableReminders.isEmpty {
                        Picker("Reminder", selection: $selectedReminder) {
                            ForEach(availableReminders, id: \.date) { reminder in
                                Text(reminder.label).tag(reminder)
                            }
                        }
                        Button("Add Reminder") {
                            if !reminders.contains(selectedReminder) {
                                reminders.append(selectedReminder)
                                reminders.sort { $0.date < $1.date }
                                if let next = availableReminders.first(where: { $0 != selectedReminder }) {
                                    selectedReminder = next
                                }
                            }
                        }
                    } else {
                        Text("All reminders added")
                            .foregroundColor(.secondary)
                    }
                }
                
                
                
            }
            .navigationTitle(countdownToEdit == nil ? "New Countdown" : "Edit Countdown")
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
                    
                    linkedEvent = CalendarAccessManager.event(with: eventIdentifier)
                }
            }
        }
        .onChange(of: hasTime) { _, newVal in
            if !newVal {
                let dateWithoutTime = Calendar.current.startOfDay(for: countdownDate)
                countdownDate = dateWithoutTime
            }
        }
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
}
