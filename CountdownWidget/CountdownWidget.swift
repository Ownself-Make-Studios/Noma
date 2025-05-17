//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            countdownItem: nil)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(),
                    countdownItem:
                .init(emoji: nil, name: "Happy Pie Day!", includeTime: false, date: .now.addingTimeInterval(
                    60 * 60 * 24 * 3
                ))
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        let items = await getCountdownItems()
        
        print("Renewing Timeline")
        print(items)
        
        // If there is no countdowns, set it to refresh NEVER
//        if(items.isEmpty){
//            return Timeline(entries: [], policy: .never)
//        }
        
        print(items.first!.name)
        print(items.first!.date)
        
        var entries: [SimpleEntry] = []
        
        if(items.isEmpty){
            entries = [
                SimpleEntry(date: .now, countdownItem: nil),
            ]
        }else{
            items.forEach { item in
                entries.append(
                    .init(date: item.date, countdownItem: item)
                )
                    
            }
//            entries = [
//                SimpleEntry(date: .now, countdownItem: items.first),
//            ]
        }
        
        // Refresh every after 1 hour
        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(3600)))
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
    
    static func predicate() -> Predicate<CountdownItem> {
        let now = Date()
        return #Predicate<CountdownItem> { $0.date >= now }
    }
    
    // Fetch all countdown items
    @MainActor
    private func getCountdownItems() -> [CountdownItem] {
        let modelContainer = CountieModelContainer.sharedModelContainer
        
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: Provider.predicate(), sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )
        
        let items = try? modelContainer.mainContext.fetch(descriptor)
        
        return items ?? [];
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let countdownItem: CountdownItem?
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(
                    .fill.tertiary,
                    for: .widget
                )
                .modelContainer(
                    CountieModelContainer.sharedModelContainer
                )
        }
        .supportedFamilies(
            [
                .accessoryRectangular,
                .systemSmall,
                .systemMedium,
                .systemLarge
            ])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultIntent: ConfigurationAppIntent {
        return ConfigurationAppIntent()
    }
}

#Preview(as: .accessoryRectangular) {
    CountdownWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        countdownItem: .SampleFutureTimer
    )
    
    
}
