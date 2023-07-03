import Foundation
import MLKit

class TraslatorUK2EN {
    
    static let shared = TraslatorUK2EN()
    private init() {}
    
    private let options = TranslatorOptions(sourceLanguage: .ukrainian, targetLanguage: .english)
    var translation: String = ""
    
    public func translateUK2EN(text: String) {
        let ukrainianEnglishTranslator = Translator.translator(options: options)
        var translatedText: String = ""
        ukrainianEnglishTranslator.downloadModelIfNeeded { error in
            guard error == nil else {
                fatalError(error.debugDescription)
            }
        }
        ukrainianEnglishTranslator.translate(text) { result, error in
            guard error == nil, let result = result else {
                fatalError(error.debugDescription)
            }
            self.translation = result
        }
    }
}
