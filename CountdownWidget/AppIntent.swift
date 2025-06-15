//
//  AppIntent.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import AppIntents
import SwiftData

struct CountdownSelection: AppEntity, Identifiable, Hashable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Countdown"))
    static var defaultQuery = CountdownQuery()
    
    let id: String
    let name: String
    let date: Date
    let emoji: String?
    
    // What shows up when the menu is displayed
    var displayRepresentation: DisplayRepresentation {
        // Show emoji if available, otherwise just show the name
        let displayName = (emoji?.isEmpty == false ? (emoji! + " ") : "") + name
        
        return DisplayRepresentation(
            title: .init(stringLiteral: displayName),
            subtitle: .init(stringLiteral: date.formatted())
        )
    }
    
    init(item: CountdownItem) {
        self.id = item.id.uuidString
        self.name = item.name
        self.date = item.date
        self.emoji = item.emoji
    }
}

struct CountdownQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CountdownSelection] {
        let items = await fetchCountdownItems()
        return items.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CountdownSelection] {
        var items = await fetchCountdownItems()
        items.sort { $0.date < $1.date }
        return items
    }
    
    @MainActor
    func fetchCountdownItems() async -> [CountdownSelection] {
        let modelContainer = CountieModelContainer.sharedModelContainer
        let descriptor = FetchDescriptor<CountdownItem>(sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)])
        let items = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        return items.map { CountdownSelection(item: $0) }
        
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Countdown Widget" }
    static var description: IntentDescription { "Access your countdowns from this widget!" }
    
    @Parameter(title: "Show Specific Countdown", default: false)
    var showSpecificCountdown: Bool?
    
    @Parameter(title: "Show Progress", default: true)
    var showProgress: Bool?
    
    @Parameter(title: "Countdown to Show")
    var countdown: CountdownSelection?
    
    // Read "ParameterSummary"
    // https://developer.apple.com/documentation/appintents/widgetconfigurationintent
    static var parameterSummary: some ParameterSummary {
        When(\ConfigurationAppIntent.$showSpecificCountdown, .equalTo, true) {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
                \.$countdown
            }
        } otherwise: {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
            }
        }
    }
}
