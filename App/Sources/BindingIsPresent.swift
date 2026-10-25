import SwiftUI

extension Binding where Value == Bool {
    /// True while `optional` holds a value; setting false clears it. For alerts and dialogs
    /// driven by an optional.
    init(isPresent optional: Binding<(some Any)?>) {
        self.init(
            get: { optional.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    optional.wrappedValue = nil
                }
            }
        )
    }
}
