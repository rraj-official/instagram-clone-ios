import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Language Selector (Top)
            HStack {
                Text("English (India)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Logo
            Image("insta_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .padding(.bottom, 40)
            
            // Inputs VStack
            VStack(spacing: 12) {
                // Email Field
                TextField("Phone number, email or username", text: $viewModel.email)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Password Field
                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            // Login Button
            Button(action: viewModel.login) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(5)
                    .opacity((viewModel.email.isEmpty || viewModel.password.isEmpty) ? 0.6 : 1.0)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            // Error Message
            if let error = viewModel.errorMessage, viewModel.showError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
            }
            
            // Forgot Password
            HStack(spacing: 4) {
                Text("Forgot your login details?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("Get help logging in.") { }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.igPrimaryText)
            }
            .padding(.top, 16)
            
            // OR Separator
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2))
                Text("OR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2))
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            // Facebook Login
            Button(action: {}) {
                HStack {
                    Image(systemName: "f.square.fill") // SF Symbol placeholder for FB
                        .foregroundColor(Color(red: 24/255, green: 119/255, blue: 242/255))
                    Text("Log in with Facebook")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 24/255, green: 119/255, blue: 242/255))
                }
            }
            
            Spacer()
            
            // Footer: Sign Up
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Sign up.") { }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 16)
            }
            .background(Color.igBackground)
        }
    }
}
