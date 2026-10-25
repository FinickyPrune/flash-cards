import SwiftUI

extension View {
    /// Shows a failed save; `message` is the error's description and is cleared on dismiss.
    func saveErrorAlert(_ message: Binding<String?>) -> some View {
        alert(
            "Couldn't Save Changes",
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: {
                    if !$0 {
                        message.wrappedValue = nil
                    }
                }
            ),
            presenting: message.wrappedValue
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { text in
            Text(text)
        }
    }
}
