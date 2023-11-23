import Alamofire
import Network
import Foundation
import Security

class NetworkManager {
    static func fetchUserDataAndMetrics(memberId: Int, completion: @escaping (UserInfo?) -> Void) {
        guard let url = URL(string: "http://192.168.0.152:3000/userDataAndMetrics/\(memberId)") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                do {
                    let userData = try JSONDecoder().decode(UserInfo.self, from: data)
                    completion(userData)
                } catch {
                    print("Error decoding user data: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
}
