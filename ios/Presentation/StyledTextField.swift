import SwiftUI

struct StyledTextField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var onEditingChanged: ((Bool) -> Void)? = nil
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        TextField(placeholder, text: $text, onEditingChanged: onEditingChanged ?? { _ in }, onCommit: onCommit ?? {})
            .keyboardType(keyboardType)
            .submitLabel(.done)
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .foregroundColor(Color.white)
            .accentColor(Color.white)
    }
}
