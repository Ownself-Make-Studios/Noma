//
//  AddCountdownView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import WidgetKit
import EmojiPicker




struct AddCountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var emoji: Emoji?;
    @State var name: String = ""
    @State var showEmojiPicker: Bool = false;
    
    // Initial state is the current date for the start of day (12am)
    @State var date: Date = Calendar.current.startOfDay(for: Date.now);
    
    @State var hasTime: Bool = false;
    @State var reminders: [CountdownReminder] = [];
    
    @State var selectedColor: Color = .red
    
    // Simplified: Selected reminder for the picker
    @State private var selectedReminder: CountdownReminder = .FIVE_MIN
    
    var isSubmitDisabled: Bool {
        name.isEmpty
    }
    
    var onAdd: (() -> Void)? = nil
    
    func handleAddItem(){
        print("Adding item")
        print(name)
        print(date)
        print(selectedColor)
        
        let item: CountdownItem = CountdownItem(
            emoji: emoji?.value,
            name: name,
            includeTime: hasTime,
            date: date)
        
        print(item)
        
        modelContext.insert(item)
        try? modelContext.save()
        
        //        Reload all widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget", )
        dismiss()
        onAdd?()
    }
    
    var body: some View {
        NavigationStack{
            // A square box with an emoji icon that when clicked open the emoji keyboard
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(emoji?.value ?? "")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                    .onTapGesture {
                        showEmojiPicker.toggle()
                    }
                Text("Tap to select emoji")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            
            Form{
                
                //                Section("Countdown Details"){
                //                    LabeledContent("Emoji"){
                //                        TextField("Emoji", text: $emoji)
                //                    }
                //
                TextField("Name of Countdown", text: $name)
                
                Toggle("Include Time", isOn: $hasTime)
                DatePicker("Date",
                           selection: $date,
                           in: Date.now...,
                           displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                //                }
                
                //                Section("Reminders"){
                //                    DatePicker("Remind me on...", selection: $date, displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                //                }
                //
                //                Section("Customization"){
                //                    ColorPicker("Color", selection: $selectedColor)
                //                }
                
                //                A section for reminders which lists down a select option for 1 day, 1 week, 1 month, 1 year and custom date. It has a button at the bottom to add a new reminder. The user can set multiple reminders for an event
                Section("Reminders") {
                    // Show reminders in chronological order
                    ForEach(reminders.sorted(by: { $0.date < $1.date }), id: \.date) { reminder in
                        HStack {
                            Text(reminder.label)
                        }
                    }
                    .onDelete { indexSet in
                        reminders.remove(atOffsets: indexSet)
                    }

                    // Only show picker options that haven't been added yet
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
                                // Update selectedReminder to next available, if any
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
            .navigationTitle("New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbar{
                Button("Add") {
                    handleAddItem()
                }.disabled(isSubmitDisabled)
            }.sheet(isPresented: $showEmojiPicker){
                NavigationView{
                    
                    EmojiPickerView(selectedEmoji: $emoji)
                        .navigationTitle("Select Emoji")
                        .navigationBarTitleDisplayMode(.inline)
                }
                
            }
            
        }
        .onChange(of: hasTime){
            _, new in
            
            if(!new){
                // Remove time from date
                let dateWithoutTime = Calendar.current.startOfDay(for: date)
                date = dateWithoutTime
            }
        }
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
}
