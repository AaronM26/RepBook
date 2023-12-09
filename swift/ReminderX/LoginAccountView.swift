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
        guard let url = URL(string: "http://192.168.0.146:3000/login") else {
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
        guard let data = data else {
            print("No data received from login response")
            errorMessage = "Invalid server response"
            return
        }
        
        print("Received data: \(String(describing: String(data: data, encoding: .utf8)))")
        
        guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
            print("Failed to decode login response")
            errorMessage = "Invalid server response"
            return
        }
        
        print("Decoded login response: memberId = \(loginResponse.memberId), authKey = \(loginResponse.authKey)")
        
        // After successful login
        if let userIdData = "\(loginResponse.memberId)".data(using: .utf8),
           let authKeyData = loginResponse.authKey.data(using: .utf8) {
            
            let userIdSaveStatus = KeychainManager.save(userIdData, service: "YourAppService", account: "userId")
            let authKeySaveStatus = KeychainManager.save(authKeyData, service: "YourAppService", account: "authKey")
            
            print("UserID save status: \(userIdSaveStatus), AuthKey save status: \(authKeySaveStatus)")
            
            if userIdSaveStatus == noErr, authKeySaveStatus == noErr {
                print("Both User ID and Auth Key saved successfully")
                
                // Fetch user data and metrics
                NetworkManager.fetchUserDataAndMetrics(memberId: loginResponse.memberId, authKey: loginResponse.authKey) { userInfo in
                    if let userInfo = userInfo {
                        DispatchQueue.main.async {
                            print("Fetched user info successfully: \(userInfo)")
                            // Handle the userInfo
                        }
                    } else {
                        print("Failed to fetch user info")
                    }
                }
                isAuthenticated = true
            } else {
                errorMessage = "Failed to save User ID or Auth Key"
                print(errorMessage)
            }
        } else {
            errorMessage = "Failed to process User ID or Auth Key"
            print(errorMessage)
        }
    }
    
    struct LoginResponse: Decodable {
        let memberId: Int
        let authKey: String

        enum CodingKeys: String, CodingKey {
            case memberId = "member_id"
            case authKey = "auth_key"
        }
    }
}
