//
//  Countdown.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Countdown: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 30){
            
//            Image(
//                systemName: "timer.circle"
//            )
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 100)
            
            ZStack {
                
            
            CountdownListItemView(item: CountdownItem.Graduation)
                .padding()
                .background(
                    .white,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .shadow(color: Color.black.opacity(1), radius: 8, x: 0, y: 4)
                        
                )
                .rotationEffect(.degrees(5))
                .scaleEffect(1.03)

                  CountdownListItemView(item: CountdownItem.Graduation)
                .padding()
                .background(
                    .white,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        
                    
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .shadow(color: Color.black.opacity(1), radius: 8, x: 0, y: 4)
                        
                )
                .rotationEffect(.degrees(-3))
                .scaleEffect(1.02)
                
                          CountdownListItemView(item: CountdownItem.Graduation)
                .padding()
                .background(
                    .white,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        
                    
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .shadow(color: Color.black.opacity(1), radius: 8, x: 0, y: 4)
                        
                )
               
            }

            
            VStack {
                Text("Create Meaningful Countdowns")
                    .font(.title)
                    .bold()
                Text("From big days like graduation 🎓 to simple plans like your next vacation 🏖️ — it’s just a few taps away.")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Countdown()
}
