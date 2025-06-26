//
//  Countdown.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Widget: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 30){
            
//            Image(
//                systemName: "timer.circle"
//            )
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 100)
            
            Image("WidgetDemo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack {
                Text("Stay Updated at a Glance")
                    .font(.title)
                    .bold()
                Text("Add Countie widgets to your Lock Screen or Home Screen for quick views of your upcoming milestones.")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Widget()
}
