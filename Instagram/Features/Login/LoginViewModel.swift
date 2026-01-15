import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var showError = false
    
    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    func login() {
        // Hardcoded credentials as per requirements
        if email == "user@example.com" && password == "password123" {
            withAnimation {
                isLoggedIn = true
                errorMessage = nil
                showError = false
            }
        } else {
            errorMessage = "Invalid credentials. Please try again."
            showError = true
        }
    }
}


