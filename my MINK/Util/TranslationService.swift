//
//  TranslationService.swift
//  my MINK
//
//  Created by Vijay Rathore on 10/05/24.
//

import Foundation

class TranslationService {
    
    // Singleton instance
    static let shared = TranslationService()

    // Private initializer to prevent instantiation from outside
    private init() {}

    func translateText(text: String, completion: @escaping (String) -> Void) {
        
        print(text)
        let apiKey = "AIzaSyClxuD0JmWn1qG2QecBXuuaFzsdv-jcuMw"
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2?target=en&q=\(encodedText)&key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let translation = try? JSONDecoder().decode(TranslationResponse.self, from: data) {
                completion(translation.data.translations.first?.translatedText ?? "")
            }
           
        }
        task.resume()
    }

    struct TranslationResponse: Codable {
        struct Data: Codable {
            struct Translation: Codable {
                let translatedText: String
            }
            let translations: [Translation]
        }
        let data: Data
    }
}
