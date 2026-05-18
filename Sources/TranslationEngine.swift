import Foundation

class TranslationEngine: ObservableObject {
    @Published var translatedText: String = ""
    @Published var isTranslating: Bool = false
    
    func translate(text: String, completion: @escaping (String) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion("")
            return
        }
        
        DispatchQueue.main.async {
            self.isTranslating = true
        }
        
        // Fast, zero-dependency cURL translation to Google Translate API (reliable, direct fallback)
        guard let encodedText = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion("")
            return
        }
        
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=\(encodedText)"
        guard let url = URL(string: urlString) else {
            completion("")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.isTranslating = false
                }
            }
            
            if let error = error {
                print("Translation request failed: \(error.localizedDescription)")
                completion("[Translation Error]")
                return
            }
            
            guard let data = data else {
                completion("")
                return
            }
            
            do {
                // Parse standard Google single translation JSON array format:
                // [[["translated", "source", ...]]]
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                   let firstList = json.first as? [Any] {
                    var translationParts = [String]()
                    for item in firstList {
                        if let part = item as? [Any],
                           let translatedSegment = part.first as? String {
                            translationParts.append(translatedSegment)
                        }
                    }
                    let combinedTranslation = translationParts.joined(separator: " ")
                    completion(combinedTranslation)
                } else {
                    completion("")
                }
            } catch {
                print("JSON parsing failed: \(error.localizedDescription)")
                completion("")
            }
        }
        task.resume()
    }
}
