//
//  Item.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import AppIntents
import Foundation
import SwiftData

enum CountdownUnit: String, CaseIterable {
    case year, month, day, hour, minute

    var displayName: String {
        switch self {
        case .year: return "year"
        case .month: return "month"
        case .day: return "day"
        case .hour: return "hour"
        case .minute: return "minute"
        }
    }
}

struct BiggestUnit {
    let value: Int
    let unit: CountdownUnit
    var isPast: Bool { value < 0 }
}

@Model
class CountdownItem {

    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var emoji: String?
    @Attribute var name: String
    @Attribute var includeTime: Bool = false
    @Attribute var date: Date
    @Attribute var isDeleted: Bool = false

    @Attribute var createdAt: Date = Date.now

    // This is used to track when the countdown should start counting down from. This is so that we can visualize how long the countdown has been running using a progress bar or etc
    @Attribute var countSince: Date = Date.now

    @Attribute var calendarEventIdentifier: String?

    init(
        emoji: String?,
        name: String,
        includeTime: Bool,
        date: Date,
        calendarEventIdentifier: String? = nil
    ) {
        self.emoji = emoji
        self.name = name
        self.includeTime = includeTime
        self.date = date
        self.calendarEventIdentifier = calendarEventIdentifier
        self.isDeleted = false
    }

    /**
     Calculates the date difference between two dates (used by functions below)
     */
    var dateDifference: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: Date.now,
            to: self.date
        )
    }

    private func getLeft(unit: Calendar.Component) -> Int {
        return dateDifference.value(for: unit)!
    }

    /**
     Returns the time remaining as a String for widget (which goes up to days and hours)
     */
    var timeRemainingWidgetString: String {
        if getLeft(unit: .day) <= 0 {
            // Return in hours if less than a day remaining
            return getTimeRemainingString(since: Date.now, units: [.hour])
        }
        //        return getTimeRemainingString(since: Date.now, units: [.day, .hour])
        return getTimeRemainingString(since: Date.now, units: [.day])
    }

    //    var timeRemainingWidgetShortString: String {
    //        return getTimeRemainingString(since: Date.now, units: [.day, .hour], unitsStyle: .abbreviated)
    //    }

    /**
     Returns the time remaining as a String for widget (which goes up to years, months, days, hours, minutes and seconds)
     */
    var timeRemainingString: String {
        if getLeft(unit: .day) <= 0 {
            // Return in hours if less than a day remaining
            return getTimeRemainingString(since: Date.now, units: [.hour])
        }

        return getTimeRemainingString(since: Date.now, units: [.day])
        //        return getTimeRemainingString(since: Date.now, units: [.year, .month, .day, .hour, .minute, .second])
    }

    func getTimeRemainingFn(since: Date = Date.now) -> String {
        if getLeft(unit: .day) <= 0 {
            // Return in hours if less than a day remaining
            return getTimeRemainingString(since: since, units: [.hour])
        }

        return getTimeRemainingString(since: since, units: [.day])
    }

    var timeRemainingStringDetailed: String {
        // This is the detailed version which includes years, months, days, hours, minutes and seconds
        return getTimeRemainingString(
            since: Date.now,
            units: [.day, .hour, .minute, .second],
            unitsStyle: .full
        )
    }

    /**
     Returns the time remaining as a String for widget (which goes up to years, months, days, hours, minutes and seconds)
     */
    var timeRemainingPassedString: String {
        // If the countdown has passed more than a day, show days otherwise show hours
        if getLeft(unit: .day) <= 0 {
            // Return in days if more than a day passed
            return getTimeRemainingString(since: Date.now, units: [.day])
        }

        return getTimeRemainingString(since: Date.now, units: [.hour])
    }

    func getTimeRemainingPassedFn(since: Date = Date.now) -> String {
        // If the countdown has passed more than a day, show days otherwise show hours
        if getLeft(unit: .day) <= 0 {
            // Return in days if more than a day passed
            return getTimeRemainingString(since: since, units: [.day])
        }

        return getTimeRemainingString(since: since, units: [.hour])
    }

    /**
     Calculates the progress of the countdown since a given date.
     */
    private func calculateProgress(since: Date = Date()) -> Double {
        let totalInterval = date.timeIntervalSince(countSince)
        let elapsedInterval = since.timeIntervalSince(countSince)

        guard totalInterval > 0 else { return 1.0 }  // If date is before since, consider complete
        let percent = min(max(elapsedInterval / totalInterval, 0), 1)
        return percent  // Return the raw percent (0...1), rounding only in the view
    }

    func getTimeRemainingString(
        since: Date = Date(),
        units: NSCalendar.Unit = [.year, .month, .day, .hour],
        unitsStyle: DateComponentsFormatter.UnitsStyle = .full
    ) -> String {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = units
        dateComponentsFormatter.unitsStyle = unitsStyle
        var dateRemainingText = dateComponentsFormatter.string(
            from: since,
            to: date
        )!

        // Time that has passed will have a minus prefix e.g. -1 day ago
        if dateRemainingText.hasPrefix("-") {
            dateRemainingText = "\(dateRemainingText.dropFirst()) ago"
        } else {
            dateRemainingText = "\(dateRemainingText)"
        }

        return dateRemainingText

    }

    /**
     Formatted date string
     */
    var formattedDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

    /**
     Calculates the percentage of time elapsed between countSince and date.
     Returns a value between 0 (just started) and 1 (fully elapsed or past).
     */
    var progress: Double {
        let totalInterval = date.timeIntervalSince(countSince)
        let elapsedInterval = Date().timeIntervalSince(countSince)
        guard totalInterval > 0 else { return 1.0 }  // If date is before countSince, consider complete
        let percent = min(max(elapsedInterval / totalInterval, 0), 1)
        return percent  // Return the raw percent (0...1), rounding only in the view
    }

    /**
     * Returns the progress as a string formatted to 2 decimal places (e.g., "23.34")
     */
    var progressString: String {
        String(format: "%.2f", progress * 100)
    }

    /// Returns the biggest (absolute) non-zero unit in the countdown (e.g., 2 years, 3 days, 4 hours, etc.)
    /// If the event has passed, the value will be negative and isPast will be true.
    var biggestUnit: BiggestUnit? {
        let diff = dateDifference
        if let years = diff.year, years != 0 {
            return BiggestUnit(value: years, unit: .year)
        }
        if let months = diff.month, months != 0 {
            return BiggestUnit(value: months, unit: .month)
        }
        if let days = diff.day, days != 0 {
            return BiggestUnit(value: days, unit: .day)
        }
        if let hours = diff.hour, hours != 0 {
            return BiggestUnit(value: hours, unit: .hour)
        }
        if let minutes = diff.minute, minutes != 0 {
            return BiggestUnit(value: minutes, unit: .minute)
        }
        return nil
    }

    /// Returns a short string for the biggest unit (e.g. "2d", "2y", "2h", "2h ago"). Anything below hours is rounded up to hours.
    var biggestUnitShortString: String {
        let diff = dateDifference
        if let years = diff.year, years != 0 {
            let absValue = abs(years)
            return years < 0 ? "\(absValue)y ago" : "\(absValue)y"
        }
        if let months = diff.month, months != 0 {
            let absValue = abs(months)
            return months < 0 ? "\(absValue)m ago" : "\(absValue)m"
        }
        if let days = diff.day, days != 0 {
            let absValue = abs(days)
            return days < 0 ? "\(absValue)d ago" : "\(absValue)d"
        }
        // For hours and below, round up to hours
        var hours = diff.hour ?? 0
        let minutes = diff.minute ?? 0
        if hours == 0 && minutes != 0 {
            // If there are minutes but no hours, round up to 1 hour (or -1 hour if negative)
            hours = minutes > 0 ? 1 : -1
        } else if hours != 0 && minutes != 0
            && ((hours > 0 && minutes > 0) || (hours < 0 && minutes < 0))
        {
            // If both hours and minutes are positive or both negative, round up
            hours += hours > 0 ? 1 : -1
        }
        if hours != 0 {
            let absValue = abs(hours)
            return hours < 0 ? "\(absValue)h ago" : "\(absValue)h"
        }
        return "?"
    }
}

extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(
        emoji: "😊",
        name: "Demo Item (Future)",
        includeTime: true,
        date: Date.distantFuture
    )

    public static var SamplePastTimer = CountdownItem(
        emoji: nil,
        name: "Demo Item (Past)",
        includeTime: true,
        date: Date.now.addingTimeInterval(-86400)
    )

    public static var Graduation = CountdownItem(
        emoji: "🎓",
        name: "Graduation",
        includeTime: false,
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30)
    )  // 30 days from now
}
