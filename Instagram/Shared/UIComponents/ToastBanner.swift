import SwiftUI

struct ToastBanner: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isError ? Color.red : Color.green)
            .cornerRadius(8)
            .padding(.horizontal)
            .shadow(radius: 4)
    }
}


