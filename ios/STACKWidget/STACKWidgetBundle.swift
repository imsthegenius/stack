import WidgetKit
import SwiftUI

@main
struct STACKWidgetBundle: WidgetBundle {
    var body: some Widget {
        STACKDaysWidget()
        STACKCircularWidget()
        STACKInlineWidget()
        STACKWidget()
    }
}
