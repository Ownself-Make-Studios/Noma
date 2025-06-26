import WidgetKit
import SwiftUI
import SwiftData

struct MultipleCountdownWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
        
    }
}