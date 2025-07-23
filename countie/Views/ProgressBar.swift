//
//  ProgressBar.swift
//  countie
//
//  Created by Nabil Ridhwan on 23/7/25.
//  From: https://youtu.be/ikoS43QtLYE?si=w4GUBABBG2l10Qnz

import SwiftUI

struct CircularProgressBar: View {
    var progress: Float
    var color: Color = Color.green
    
    var body: some View {
        ZStack {
//            Circle()
//                .stroke(lineWidth: 3.0)
//                .opacity(0.20)
//                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 2.7, lineCap: .round, lineJoin: .round))
                .foregroundColor (color).rotationEffect (Angle(degrees: 270))
        }
        
    }
}
