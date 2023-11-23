import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct MakeAccountView: View {
    @Binding var isAuthenticated: Bool
    @State private var isAccountInfoCompleted = false
    @State private var isEmailValid: Bool = true
    @State private var passwordWarning: String = ""
    
    // Account Info
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth = Date()
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Health Metrics
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = ""
    @State private var workoutFrequency: String = ""
    @State private var appUsagePurpose: String = ""
    @State private var workoutType: String = ""
    
    let genders = ["Male", "Female", "Other"]
    let workoutFrequencies = ["Daily", "Weekly", "Monthly"]
    let workoutTypes = ["Home", "Gym"]
    let appPurposes = ["Weight Loss", "Build Muscle", "Calisthenics"]
    
    var body: some View {
        VStack {
            Image("login_banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .padding(20)
            
            accountInfoForm
            
            Spacer()
        }
        .background(Color.white.opacity(0.5).edgesIgnoringSafeArea(.all))
    }

    
    // MARK: - Account Info Form
    var accountInfoForm: some View {
        VStack {
            formField(title: "First Name", text: $firstName)
            formField(title: "Last Name", text: $lastName)
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            
            HStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: email) { _ in validateEmail() }
                
                if !isEmailValid {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
                }
            }
            
            HStack {
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .onChange(of: password) { _ in validatePassword() }
                
                if !passwordWarning.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 30)
                }
            }
            
            if !passwordWarning.isEmpty {
                Text(passwordWarning)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if allFieldsValid() {
                Button("Continue to Health Metrics") {
                    isAccountInfoCompleted = true
                    signUpUser()
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
            }
        }
    }
    
    private func formField(title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding()
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
    }
    
    private func validatePassword() {
        passwordWarning = ""
        
        if password.count < 8 {
            passwordWarning += "Password must be at least 8 characters. "
        }
        
        if !passwordContainsNumber() {
            passwordWarning += "Password must contain at least one number."
        }
    }
    
    private func passwordContainsNumber() -> Bool {
        let numberRange = password.rangeOfCharacter(from: .decimalDigits)
        return numberRange != nil
    }
    
    private func validateEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
    }
    
    private func allFieldsValid() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isEmailValid && !password.isEmpty
    }
    func signUpUser() {
        // Initialize the DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Prepare the URL
        guard let url = URL(string: "http://192.168.0.152:3000/signup") else { return }
        
        // Format the dateOfBirth to a string
        let dobString = dateFormatter.string(from: dateOfBirth)
        
        // Create the JSON data to send
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": dobString,
            "email": email,
            "password": password
        ]
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the user data to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            print("Failed to encode user data")
            return
        }
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201,
               let data = data,
               let result = try? JSONDecoder().decode([String: Int].self, from: data),
               let userId = result["member_id"] {
                
                // Save userId securely in Keychain and authenticate the user
                if let userIdData = "\(userId)".data(using: .utf8) {
                    KeychainManager.save(userIdData, service: "YourAppService", account: "userId")
                    DispatchQueue.main.async {
                        isAuthenticated = true
                    }
                }
            }
        }.resume()
    }
}
