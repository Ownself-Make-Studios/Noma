//
//  EditCountdownView.swift
//  countie
//
//  Created by Nabil Ridhwan on 28/10/24.
//

import SwiftUI
import WidgetKit

struct EditCountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var countdownItem: CountdownItem;
    @State var name: String = ""
    @State var date: Date = Date.now
    
    @State var hasTime: Bool = false;
    
    @State var selectedColor: Color = .red
    
    var isSubmitDisabled: Bool {
        name.isEmpty
    }
    
    func handleEditCountdownItem(){
        countdownItem.name = name;
        countdownItem.date = date;
        
        try? modelContext.save()
        
        // Dismiss window
        dismissWindow()
    }
    
    func dismissWindow(){
        // Reload all widget timelines
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
                
            }
            .navigationTitle("Edit Countdown")
            .toolbar{
                Button("Save") {
                    handleEditCountdownItem()
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
        .onAppear{
            name = countdownItem.name
            date = countdownItem.date
        }
    }
}

#Preview {
    EditCountdownView(
        countdownItem: CountdownItem.DemoItem
    )
        .modelContainer(
            for: CountdownItem.self,
            inMemory: true
        )
}
