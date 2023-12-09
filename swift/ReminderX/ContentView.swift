import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var userInfo: UserInfo?
    @State private var userMetrics: [MemberMetric] = [] // Updated to hold an array of MemberMetric
    
    var body: some View {
        Group {
            if isAuthenticated, let userInfo = userInfo {
                MainAppView(userMetrics: userMetrics, userInfo: userInfo)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            isAuthenticated = KeychainManager.load(service: "YourAppService", account: "userId") != nil
                       fetchUserDataIfNeeded()
                       fetchUserMetricsIfNeeded()
        }
        .environment(\.colorScheme, .light)
    }
    
    private func fetchUserDataIfNeeded() {
        if isAuthenticated {
            // Retrieve the user ID and auth key from Keychain and fetch user data
            if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
               let memberIdString = String(data: memberIdData, encoding: .utf8),
               let memberId = Int(memberIdString),
               let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
               let authKey = String(data: authKeyData, encoding: .utf8) {
                
                NetworkManager.fetchUserDataAndMetrics(memberId: memberId, authKey: authKey) { fetchedUserInfo in
                    DispatchQueue.main.async {
                        self.userInfo = fetchedUserInfo
                    }
                }
            }
        }
    }
    private func fetchUserMetricsIfNeeded() {
        if isAuthenticated {
            // Retrieve the user ID and auth key from Keychain and fetch user metrics
            if let memberIdData = KeychainManager.load(service: "YourAppService", account: "userId"),
               let memberIdString = String(data: memberIdData, encoding: .utf8),
               let memberId = Int(memberIdString),
               let authKeyData = KeychainManager.load(service: "YourAppService", account: "authKey"),
               let authKey = String(data: authKeyData, encoding: .utf8) {
                
                NetworkManager.fetchMemberMetrics(memberId: memberId, authKey: authKey) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedMetrics):
                            self.userMetrics = fetchedMetrics
                        case .failure(let error):
                            print("Error fetching user metrics: \(error)")
                            // Handle the error accordingly
                        }
                    }
                }
            }
        }
    }
}
struct MainAppView: View {
    var userMetrics: [MemberMetric] // Array of MemberMetric
    var userInfo: UserInfo
    @State private var selection: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                Group {
                    switch selection {
                    case 0:
                        HomeView(userInfo: userInfo, userMetrics: userMetrics)
                                       case 1:
                                           WorkoutView()
                                       case 2:
                                           AiView()
                                       case 3:
                        SettingsView(userInfo: userInfo, userMetrics: userMetrics)
                                       default:
                                               EmptyView()
                                           }
                }
            }
            CustomTabBar(selection: $selection)
        }
        .environment(\.font, .custom("HelveticaNeue", size: 16))
            }
    
    func tabText(for index: Int) -> String {
        switch index {
        case 0:
            return "Home"
        case 1:
            return "Folders"
        case 2:
            return "Calendar"
        case 3:
            return "Talk to AI"
        default:
            return ""
        }
    }
}
