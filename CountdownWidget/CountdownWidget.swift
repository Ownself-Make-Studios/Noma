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
    // https://calebhearth.com/using-widgetkit-with-swiftdata
    var sharedModelContainer: ModelContainer = { // Note that we create and assign this value;
        let schema = Schema([CountdownItem.self])        // it is not a computed property.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @Query private var items: [CountdownItem] = []
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct CountdownWidgetEntryView : View {
    var entry: Provider.Entry
    @Query var model: [CountdownItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            //            Image("CountieLogo")
            //                .resizable()
            //                .frame(width: 40, height: 40)
            
            if(model.isEmpty){
                Text("Nothing to see here")
            }else{
                Text(model[0].name)
                    .font(.headline)
                
                Text(model[0].daysLeft)
                    .font(.caption)
                
                
            }
            
            //            Text("My Birthday!")
            //                .font(.headline)
            //
            //            Text("45 Days")
            //                .font(.caption)
            //
            //            Text("June 10, 2025")
            //                .font(.caption2)
            //
            //            Text(entry.date, style: .time)
            //
            //            Text("Favorite Emoji:")
            //            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(for: [CountdownItem.self])
        }
        .supportedFamilies([.accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    CountdownWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
