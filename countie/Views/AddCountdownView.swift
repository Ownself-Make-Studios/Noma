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

    @State var name: String = "";
    
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
            Form{
                Section("Countdown Details"){
                    
                    LabeledContent("Name"){
                        TextField("My Birthday", text: $name)
                    }
                    Toggle("Include Time", isOn: $hasTime)
                    DatePicker("Date", selection: $date, displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                }
                
//                Section("Reminders"){
//                    DatePicker("Remind me on...", selection: $date, displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
//                }
//                
//                Section("Customization"){
//                    ColorPicker("Color", selection: $selectedColor)
//                }
            }
            .navigationTitle("Add Countdown")
            .toolbar{
                Button("Add") {
                    handleAddItem()
                }.disabled(isSubmitDisabled)
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
