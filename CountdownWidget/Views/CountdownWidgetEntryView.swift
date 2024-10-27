//
//  CountdownWidgetEntryView.swift
//  countie
//
//  Created by Nabil Ridhwan on 25/10/24.
//

import SwiftUI
import SwiftData

struct CountdownWidgetEntryView : View {
    var entry: Provider.Entry
    @Query var model: [CountdownItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            if(model.isEmpty){
                Text("No countdowns :(")
            }else{
                Text(model[0].name)
                    .font(.headline)
                
                Text(model[0].timeRemainingString)
                    .font(.caption)
            }
        }
    }
}
