//
//  AddCountdownView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import WidgetKit

struct AddCountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Optional countdown to edit
    var countdownToEdit: CountdownItem? = nil
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var showEmojiAlert: Bool = false
    @State var emojiText: String = ""
    
    @State var countdownDate: Date = Calendar.current.startOfDay(for: Date.now)
    @State var countSinceDate: Date = Calendar.current.startOfDay(for: Date.now)
    @State var hasTime: Bool = false
    @State var reminders: [CountdownReminder] = []
    @State var selectedColor: Color = .red
    @State private var selectedReminder: CountdownReminder = .FIVE_MIN
    
    var isSubmitDisabled: Bool {
        name.isEmpty && emoji.isEmpty
    }
    
    var onAdd: (() -> Void)? = nil
    
    // MARK: - Init
    init(countdownToEdit: CountdownItem? = nil, onAdd: (() -> Void)? = nil) {
        self.countdownToEdit = countdownToEdit
        self.onAdd = onAdd
        // _property = State(initialValue:) cannot be set here, must use .onAppear
        

    }
    
    //        name: event.title,
//        countdownDate: event.startDate,
//        hasTime: !event.isAllDay,
//        onAdd: {
//            onSelectEvent?(event)
//        }
    
    init(name: String = "", countdownDate: Date = Calendar.current.startOfDay(for: Date.now), hasTime: Bool = false, onAdd: (() -> Void)? = nil) {
        self.name = name
        self.countdownDate = countdownDate
        self.hasTime = hasTime
        self.onAdd = onAdd
    }
    
    func handleAddItem() {
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
            // TODO: Save reminders and color if needed
            modelContext.insert(item)
            try? modelContext.save()
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget")
        dismiss()
        onAdd?()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(emoji)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                    .onTapGesture {
                        showEmojiAlert = true
                        emojiText = emoji
                    }
                Text("Tap to set an emoji")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            
            Form {
                TextField("Name of Countdown", text: $name)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbar {
                Button(countdownToEdit == nil ? "Add" : "Save") {
                    handleAddItem()
                }.disabled(isSubmitDisabled)
            }
            .alert("Enter Emoji", isPresented: $showEmojiAlert) {
                TextField("Emoji", text: $emojiText)
                    .onChange(of: emojiText) { _, newValue in
                        if newValue.count > 1 {
                            emojiText = String(newValue.prefix(1))
                        }
                    }
                Button("OK") {
                    if emojiText.isSingleEmoji {
                        emoji = emojiText
                    } else {
                        emoji = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enter a single emoji.")
            }
        }
        .onAppear {
            if let editing = countdownToEdit {
                emoji = editing.emoji ?? ""
                name = editing.name
                hasTime = editing.includeTime
                countdownDate = editing.date
                countSinceDate = editing.countSince
                // TODO: Load reminders and color if needed
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

// Emoji validation extension
extension String {
    var isSingleEmoji: Bool {
        count == 1 && first?.isEmoji == true
    }
}

extension Character {
    var isEmoji: Bool {
        unicodeScalars.first?.properties.isEmojiPresentation == true ||
        unicodeScalars.first?.properties.isEmoji == true
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
}
