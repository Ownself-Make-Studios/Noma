//
//  Welcome.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Final: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 30){
            
            Image(
                "Cat"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            
            VStack {
                Text("That's all!")
                    .font(.title)
                    .bold()
                Text("Let's start counting! (p.s. the cat says meow!)")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Final()
}
