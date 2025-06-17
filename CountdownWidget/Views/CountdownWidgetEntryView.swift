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
                    CountdownWidgetSmallView(countdownItem: countdownItem, showProgress: entry.showProgress)
                case .systemMedium:
                    CountdownWidgetMediumView(countdownItem: countdownItem, showProgress: entry.showProgress)
                case .systemLarge:
                    CountdownWidgetLargeView(countdownItem: countdownItem, showProgress: entry.showProgress)
                case .accessoryRectangular:
                    CountdownWidgetAccessoryRectangularView(countdownItem: countdownItem, showProgress: entry.showProgress)
                case .accessoryInline:
                    CountdownWidgetAccessoryInlineView(countdownItem: countdownItem, showProgress: entry.showProgress)
                case .accessoryCircular:
                    CountdownWidgetAccessoryCircularView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                default:
                    CountdownWidgetSmallView(countdownItem: countdownItem, showProgress: entry.showProgress)
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
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.title)
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            
            if showProgress {
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
                    
                    Text("\(countdownItem.progressString)%")
                        .font(.caption)
                        .opacity(0.4)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetMediumView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.title)
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            
            if showProgress {
                
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
                    
                    Text("\(countdownItem.progressString)%")
                        .font(.caption)
                        .opacity(0.4)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetLargeView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.title)
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(countdownItem.timeRemainingString)
                .font(.caption)
                .opacity(0.6)
            
            if showProgress {
                
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
                    
                    Text("\(countdownItem.progressString)%")
                        .font(.caption)
                        .opacity(0.4)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetAccessoryRectangularView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool
    
    // Show time remaining with progress percentage if showProgress is true
    var timeRemainingString: String {
        if showProgress {
            return countdownItem.timeRemainingString + " (\(countdownItem.progressString)%)"
        } else {
            return countdownItem.timeRemainingString
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(countdownItem.emoji ?? "") \(countdownItem.name)")
                .font(.body)
                .bold()
                .lineLimit(1)
            
            Text(timeRemainingString)
                .font(.caption)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetAccessoryInlineView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool
    
    // Show time remaining with progress percentage if showProgress is true
    var timeRemainingString: String {
        if showProgress {
            return countdownItem.timeRemainingString + " (\(countdownItem.progressString)%)"
        } else {
            return countdownItem.timeRemainingString
        }
    }

    var body: some View {
        HStack {
            Text("\(countdownItem.emoji ?? "") \(timeRemainingString)")
                .font(.body)
        }
    }
}

struct CountdownWidgetAccessoryCircularView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool
    
    var timeRemainingString: String {
        if showProgress {
            "\(Int(countdownItem.progress * 100))%"
        }else{
            countdownItem.biggestUnitShortString
        }
        
    }

    var body: some View {
        ZStack{
            Gauge(value: countdownItem.progress) {
                Text(timeRemainingString)
            } currentValueLabel: {
                Text(countdownItem.emoji ?? "")
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}
