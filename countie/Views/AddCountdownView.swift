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
    @State var updateCountdownWhenEventChanges: Bool = false
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
            
            if let event = linkedEvent {
                item.calendarEventIdentifier = event.eventIdentifier
            }
            
            modelContext.insert(item)
            try? modelContext.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
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
                            showEmojiPicker = true
                        }
                        .emojiPicker(isPresented: $showEmojiPicker, selectedEmoji: $emoji)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                
                Section("Name"){
                    TextField("Graduation, Anniversary, etc.", text: $name)
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
                        
                        Button("Unlink Event") {
                        }
                        
                        Toggle("Update countdown when event changes", isOn: $updateCountdownWhenEventChanges)
                            .disabled(true) // Disable this for now, as we don't have the logic implemented yet
                        
                    }
                }
                
                Section("Countdown Settings") {
                    Toggle("Include time", isOn: $hasTime)
                    DatePicker("Countdown Date\(hasTime ? " & Time" : "")",
                               selection: $countdownDate,
                               in: Date.now...,
                               displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                    DatePicker("Count since",
                               selection: $countSinceDate,
                               displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                    Text("Progress will be calculated from the date selected in \"Count Since\".")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                
                
                //                Section("Reminders") {
                //                    Button("Add Reminder"){
                //
                //                    }
                //                }
                
                
                
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
