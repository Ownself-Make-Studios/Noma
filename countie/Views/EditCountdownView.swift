//
//  EditCountdownView.swift
//  countie
//
//  Created by Nabil Ridhwan on 28/10/24.
//

import SwiftUI
import WidgetKit
import EmojiPicker

struct EditCountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var countdownItem: CountdownItem;
    @State var emoji: Emoji?;
    @State var name: String = ""
    @State var date: Date = Date.now
    @State var showEmojiPicker: Bool = false;
    
    @State var hasTime: Bool = false;
    
    @State var selectedColor: Color = .red
    
    var isSubmitDisabled: Bool {
        name.isEmpty
    }
    
    func handleEditCountdownItem(){
        countdownItem.emoji = emoji?.value;
        countdownItem.name = name;
        countdownItem.date = date;
        
        try? modelContext.save()
        
        // Dismiss window
        dismissWindow()
    }
    
    func dismissWindow(){
        // Reload all widget timelines
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
            
            Form{
                LabeledContent("Name"){
                    TextField("My Birthday", text: $name)
                }
                Toggle("Include Time", isOn: $hasTime)
                DatePicker("Date", selection: $date, displayedComponents: hasTime ? [.date, .hourAndMinute] : [.date])
                
                
            }
            .navigationTitle("Edit Countdown")
            .toolbar{
                Button("Save") {
                    handleEditCountdownItem()
                }.disabled(isSubmitDisabled)
            }
            
        }
        .sheet(isPresented: $showEmojiPicker){
            NavigationView{
                
                EmojiPickerView(selectedEmoji: $emoji)
                    .navigationTitle("Select Emoji")
                    .navigationBarTitleDisplayMode(.inline)
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
            hasTime = countdownItem.includeTime
            date = countdownItem.date
            
            if let emoji = countdownItem.emoji {
                self.emoji = .init(value: emoji, name: "emoji")
            }
        }
    }
}

#Preview {
    EditCountdownView(
        countdownItem: CountdownItem.SampleFutureTimer
    )
    .modelContainer(
        for: CountdownItem.self,
        inMemory: true
    )
}
