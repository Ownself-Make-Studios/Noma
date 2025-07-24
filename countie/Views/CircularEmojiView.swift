//
//  CircularEmojiView.swift
//  countie
//
//  Created by Nabil Ridhwan on 23/7/25.
//

import SwiftUI

struct CircularEmojiView: View {
    var emoji: String = "🎉" // Default emoji
    var progress: Float = 0.8 // Default progress value
    
    var width: Int = 34
    var brightness: Double = 0.3
    var lineWidth: CGFloat = 3.0
    var gap: CGFloat = 10.0
    var emojiSize: CGFloat = 18.0
    
    var body: some View {
        Circle()
            .frame(width: CGFloat(width))
            .foregroundStyle(Color(vibrantDominantColorOf: emoji) ?? .gray.opacity(0.3))
            .overlay {
                Text("\(emoji)")
                    .font(.system(size: emojiSize))
                
                CircularProgressBar(
                    progress: 0.8,
                    color: Color(vibrantDominantColorOf: emoji) ?? .gray.opacity(0.8),
                    lineWidth: lineWidth
                )
                .frame(width: CGFloat(CGFloat(width) + gap), height: CGFloat(CGFloat(width) + gap))
            }
        
    }
}

#Preview {
    CircularEmojiView()
}
