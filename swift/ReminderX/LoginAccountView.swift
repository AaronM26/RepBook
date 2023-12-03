import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct LoginAccountView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""  // New state for error message
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Image("login_banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(30)

            TextField("Username or Email", text: $email)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }

            // Login button
            Button(action: {
                loginUser()
            }) {
                Text("Login")
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.85))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
            }

            Spacer()

            // "Privacy Policy" text
            Button(action: {
                // Handle "Privacy Policy" action
            }) {
                Text("Privacy Policy")
                    .underline()
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
        }
        .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
    }

    func loginUser() {
        guard let url = URL(string: "http://localhost:3000/login") else {
            errorMessage = "Invalid URL"
            return
        }

        let userData: [String: Any] = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        print("Attempting login with Email: \(email), Password: \(password)")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
            } catch let error {
            errorMessage = "Failed to encode user data: \(error.localizedDescription)"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {  // Ensure UI updates are on the main thread
                if let error = error {
                    self.errorMessage = "Error occurred: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.handleSuccessfulLogin(data: data)
                    } else {
                        self.errorMessage = httpResponse.statusCode == 401 ? "Invalid credentials" : "Server error"
                    }
                } else {
                    self.errorMessage = "No server response"
                }
            }
        }.resume()
    }

    private func handleSuccessfulLogin(data: Data?) {
        guard let data = data,
              let result = try? JSONDecoder().decode([String: Int].self, from: data),
              let userId = result["member_id"] else {
            errorMessage = "Invalid server response"
            return
        }

        // After successful login
            if let userIdData = "\(userId)".data(using: .utf8) {
                let saveStatus = KeychainManager.save(userIdData, service: "YourAppService", account: "userId")
                if saveStatus == noErr {
                    isAuthenticated = true
                    
                    // Fetch user data and metrics
                    NetworkManager.fetchUserDataAndMetrics(memberId: userId) { userInfo in
                        if let userInfo = userInfo {
                            DispatchQueue.main.async {
                                // Navigate to MainAppView with userInfo
                                // You might need to store userInfo in a shared environment or pass it directly to MainAppView
                            }
                        }
                    }
                } else {
                errorMessage = "Failed to save User ID"
            }
        } else {
            errorMessage = "Failed to process User ID"
        }
    }
}
