//
//  Welcome.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 30){
            
            Image(
                "CountieLogo"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            
            VStack {
                Text("Welcome to Countie")
                    .font(.title)
                    .bold()
                Text("Track Life’s Milestones, One Countdown at a Time")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Welcome()
}
