//
//  CountdownWidgetEntryView.swift
//  countie
//
//  Created by Nabil Ridhwan on 25/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct CountdownWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            if let countdownItem = entry.countdownItem {
                switch family {
                case .systemSmall:
                    CountdownWidgetSmallView(countdownItem: countdownItem)
                case .systemMedium:
                    CountdownWidgetMediumView(countdownItem: countdownItem)
                case .systemLarge:
                    CountdownWidgetLargeView(countdownItem: countdownItem)
                case .accessoryRectangular:
                    CountdownWidgetAccessoryRectangularView(countdownItem: countdownItem)
                default:
                    CountdownWidgetSmallView(countdownItem: countdownItem)
                }
            } else {
                Text("No countdowns to display")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct CountdownWidgetSmallView: View {
    let countdownItem: CountdownItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.system(size: 16))
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                LinearProgressView(value: countdownItem.progress, shape: Capsule())
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .frame(height: 9)
                
                Text("\(Int(countdownItem.progress * 100))%")
                    .font(.caption2)
                    .opacity(0.4)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetMediumView: View {
    let countdownItem: CountdownItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.system(size: 16))
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                LinearProgressView(value: countdownItem.progress, shape: Capsule())
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .frame(height: 9)
                
                Text("\(Int(countdownItem.progress * 100))%")
                    .font(.caption2)
                    .opacity(0.4)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetLargeView: View {
    let countdownItem: CountdownItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.system(size: 16))
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                LinearProgressView(value: countdownItem.progress, shape: Capsule())
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .frame(height: 9)
                
                Text("\(Int(countdownItem.progress * 100))%")
                    .font(.caption2)
                    .opacity(0.4)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetAccessoryRectangularView: View {
    let countdownItem: CountdownItem
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(countdownItem.emoji ?? "") \(countdownItem.name)")
                .font(.system(size: 16))
                .bold()
                .lineLimit(1)
            
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
