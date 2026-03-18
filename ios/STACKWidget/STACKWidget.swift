import WidgetKit
import SwiftUI

nonisolated struct StackWidgetEntry: TimelineEntry {
    let date: Date
    let currentDays: Int
    let chapterNumber: Int
    let totalDays: Int
    let isMilestoneDay: Bool
    let milestoneLabel: String
    let pledgedToday: Bool
}

nonisolated struct StackWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StackWidgetEntry {
        StackWidgetEntry(date: .now, currentDays: 0, chapterNumber: 1, totalDays: 0, isMilestoneDay: false, milestoneLabel: "", pledgedToday: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (StackWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StackWidgetEntry>) -> Void) {
        let entry = readEntry()
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func readEntry() -> StackWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.stack.shared")
        return StackWidgetEntry(
            date: .now,
            currentDays: defaults?.integer(forKey: "widget_current_days") ?? 0,
            chapterNumber: defaults?.integer(forKey: "widget_chapter_number") ?? 1,
            totalDays: defaults?.integer(forKey: "widget_total_days") ?? 0,
            isMilestoneDay: defaults?.bool(forKey: "widget_is_milestone_today") ?? false,
            milestoneLabel: defaults?.string(forKey: "widget_milestone_label") ?? "",
            pledgedToday: defaults?.bool(forKey: "widget_pledged_today") ?? false
        )
    }
}

struct RectangularWidgetView: View {
    var entry: StackWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.currentDays) DAYS")
                .font(.system(.headline, design: .default).weight(.thin))
                .widgetAccentable()
            if entry.isMilestoneDay, !entry.milestoneLabel.isEmpty {
                Text(entry.milestoneLabel)
                    .font(.system(.caption, design: .default).weight(.light))
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct CircularWidgetView: View {
    var entry: StackWidgetEntry

    var body: some View {
        Text("\(entry.currentDays)")
            .font(.system(.title, design: .default).weight(.thin))
            .widgetAccentable()
            .containerBackground(.clear, for: .widget)
    }
}

struct InlineWidgetView: View {
    var entry: StackWidgetEntry

    var body: some View {
        Text("\(entry.currentDays) days. Stacked.")
            .containerBackground(.clear, for: .widget)
    }
}

struct SmallWidgetView: View {
    var entry: StackWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(entry.chapterNumber)")
                .font(.system(.caption2, design: .default).weight(.light))
                .foregroundStyle(Color(red: 0.29, green: 0.28, blue: 0.27))
                .tracking(1.5)
            Spacer()
            Text("\(entry.currentDays)")
                .font(.system(size: 38, weight: .thin, design: .default))
                .foregroundStyle(entry.isMilestoneDay ? Color.white : Color(red: 0.96, green: 0.95, blue: 0.93))
            Text("DAYS")
                .font(.system(.caption, design: .default).weight(.light))
                .foregroundStyle(Color(red: 0.55, green: 0.53, blue: 0.50))
                .tracking(2)
            Spacer()
            Image(systemName: entry.pledgedToday ? "checkmark" : "circle")
                .font(.system(size: 12))
                .foregroundStyle(entry.pledgedToday ? Color(red: 0.96, green: 0.95, blue: 0.93) : Color(red: 0.29, green: 0.28, blue: 0.27))
        }
        .padding(16)
        .containerBackground(.clear, for: .widget)
    }
}

struct STACKDaysWidget: Widget {
    let kind: String = "STACKDaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StackWidgetProvider()) { entry in
            RectangularWidgetView(entry: entry)
        }
        .configurationDisplayName("Days Sober")
        .description("Your count. Before you scroll.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct STACKCircularWidget: Widget {
    let kind: String = "STACKCircularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StackWidgetProvider()) { entry in
            CircularWidgetView(entry: entry)
        }
        .configurationDisplayName("STACK")
        .description("Days at a glance.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct STACKInlineWidget: Widget {
    let kind: String = "STACKInlineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StackWidgetProvider()) { entry in
            InlineWidgetView(entry: entry)
        }
        .configurationDisplayName("STACK Inline")
        .description("A quiet reminder.")
        .supportedFamilies([.accessoryInline])
    }
}

struct STACKWidget: Widget {
    let kind: String = "STACKWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StackWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("STACK")
        .description("Your count, always.")
        .supportedFamilies([.systemSmall])
    }
}
