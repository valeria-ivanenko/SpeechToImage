import Foundation
import SwiftUI
import UIKit

class Networking {
    
    static let shared = Networking()
        
    let apiURLString = "https://api.deepai.org/api/text2img"
        
    let apiKey = "6292b0a9-bd2f-4396-b1f8-9bbe14a94857"
    
    public func getImage(prompt: String) async -> URL {

        var urlBuilder = URLComponents(string: apiURLString)
            urlBuilder?.queryItems = [
                URLQueryItem(name: "text", value: prompt)
            ]

            guard let url = urlBuilder?.url else { return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_Homepage.svg/1200px-Google_Homepage.svg.png")!}

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "api-key")

            URLSession.shared.dataTask(with: request) { (data, response, error) in
          //  if let response = try? JSONDecoder().decode([APIResponse].self, from: data) {
                print(response)
                print(String(data: data!, encoding: .utf8))
            }.resume()
        return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_Homepage.svg/1200px-Google_Homepage.svg.png")!
    }
    
    public func uploadImage(url: URL) async -> Image? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                throw URLError(.badServerResponse, userInfo: ["URL" : url])
            }
            return Image(uiImage: uiImage)
        } catch {
            print(error)
        }
        return nil
    }
}
