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
    @State var name: String = "";
    @State var showEmojiPicker: Bool = false;
    
    // Initial state is the current date for the start of day (12am)
    @State var date: Date = Calendar.current.startOfDay(for: Date.now);
    
    @State var hasTime: Bool = false;
    @State var reminders: [CountdownReminder] = [];
    
    @State var selectedColor: Color = .red
    
    var isSubmitDisabled: Bool {
        name.isEmpty
    }
    
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
    }
    
    var body: some View {
        NavigationStack{
            // A square box with an emoji icon that when clicked open the emoji keyboard
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
                .padding(.vertical, 12)
            
            Form{
                
                //                Section("Countdown Details"){
                //                    LabeledContent("Emoji"){
                //                        TextField("Emoji", text: $emoji)
                //                    }
                //
                LabeledContent("Name"){
                    TextField("My Birthday", text: $name)
                }
                
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
                    
                    ForEach(reminders, id: \.date){ reminder in
                        HStack{
                            Text(reminder.label)
                            //                            Spacer()
                            //                            Text(reminder.date, style: .date)
                        }
                    }
                    .onDelete { indexSet in
                        reminders.remove(atOffsets: indexSet)
                    }
                    
                    Menu("Add Reminder"){
                        
                        Button("5 mins before"){
                            reminders.append(
                                CountdownReminder.FIVE_MIN
                            )
                        }
                        
                        Button("10 mins before")
                        {
                            reminders.append(
                                CountdownReminder.TEN_MIN
                            )
                        }
                        
                        Button("15 mins before")
                        {
                            reminders.append(
                                CountdownReminder.FIFTEEN_MIN
                            )
                        }
                        
                        Button("30 mins before")
                        {
                            reminders.append(
                                CountdownReminder.THIRTY_MIN
                            )
                            
                            
                            
                        }
                        
                        Button("1 hour before")
                        {
                            reminders.append(
                                CountdownReminder.ONE_HOUR
                            )
                        }
                        
                        Button("2 hours before")
                        {
                            reminders.append(
                                CountdownReminder.TWO_HOUR
                            )
                        }
                        
                        Button("1 day before"){
                            reminders.append(
                                CountdownReminder.ONE_DAY
                            )
                        }
                        
                        Button("2 days before"){
                            reminders.append(
                                CountdownReminder.TWO_DAY
                            )
                        }
                        
                        Button("Custom...")
                        {}
                    }
                    
                    //                    Button("Add Reminder"){
                    //                        reminders.append(
                    //                            Reminder(timing: "5 minutes before", date: Date.now)
                    //                        )
                    //                    }
                    
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
