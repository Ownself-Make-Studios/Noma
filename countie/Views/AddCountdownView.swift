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
        WidgetCenter.shared.reloadAllTimelines()
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
            }
            .navigationTitle("New Countdown")
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
