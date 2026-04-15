import WidgetKit
import SwiftUI

@main
struct FraværsmelderWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickReportWidget()
        TeamStatusWidget()
    }
}
