import SwiftUI

struct InfoSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    let title: String
    let content: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(content)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
