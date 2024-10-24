//
//  AppIntent.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Countdown Widget" }
    static var description: IntentDescription { "Access your countdowns from a widget!" }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
