import SwiftUI
import UniformTypeIdentifiers
import CoreGraphics
import Alamofire
import Network
import Foundation
import Security

class ReminderXViewModel: ObservableObject {
    @Published var folders: [Folder] = [] {
        didSet {
            saveFolders()
        }
    }
    @Published var showQuickReminderView: Bool = false
    @Published var showCreateFolderView: Bool = false
    private let foldersKey = "folders"
    
    init() {
        loadFolders()
    }
    
    private func saveFolders() {
        if let encodedFolders = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(encodedFolders, forKey: foldersKey)
        }
    }
    
    private func loadFolders() {
        if let data = UserDefaults.standard.data(forKey: foldersKey),
           let decodedFolders = try? JSONDecoder().decode([Folder].self, from: data) {
            folders = decodedFolders
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var viewModel: ReminderXViewModel
    var userInfo: UserInfo
    @State private var selection: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                Group {
                    switch selection {
                    case 0:
                        HomeView(viewModel: viewModel)
                    case 1:
                        VideoEditorHomeView()
                    case 2:
                        AiView(viewModel: viewModel)
                    case 3:
                        AiView(viewModel: viewModel)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ReminderXViewModel())
    }
}
