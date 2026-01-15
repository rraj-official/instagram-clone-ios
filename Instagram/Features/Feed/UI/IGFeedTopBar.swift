import SwiftUI

struct IGFeedTopBar: View {
    var body: some View {
        HStack {
            Image("insta_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 32) // Typical height for the wordmark
                // If the logo is black, we need to invert it for dark mode or use template rendering
                // Assuming it's a standard black PNG, we use .primary for tint if rendered as template
                .foregroundColor(.igPrimaryText) 
            
            Spacer()
            
            HStack(spacing: 20) {
                IGIcon(.heart)
                IGIcon(.messenger)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.igBackground)
    }
}

