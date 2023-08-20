import Foundation

extension String {

    var withoutHttp: String {
        return self
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidUsername() -> String? {
        let usernameRegEx = "^[a-zA-Z0-9._]+$"
        
        if self.count > 30 {
                return "Никнейм не должен превышать 30 символов"
            }
        if self.count < 3 {
            return "Никнейм должен состоять хотя бы из 3 символов"
        }
        
        do {
            let regex = try NSRegularExpression(pattern: usernameRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.isEmpty {
                return "Никнейм может состоять только из латинских букв и символа _"
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return "Неверный никнейм"
        }
        
        if self.first == "." {
            return "Нельзя никнейм начинать точкой"
        }
        
        if self.last == "." {
            return "Нельзя никнейм заканчивать точкой"
        }
        
        return nil
    }
    
    func containsCyrillicCharacters() -> Bool {
        let cyrillicRegex = ".*[А-Яа-яЁё].*"
        return self.range(of: cyrillicRegex, options: .regularExpression) != nil
    }

    func shorted(to symbols: Int) -> String {
        guard self.count > symbols else {
            return self
        }
        return self.prefix(symbols) + " ..."
    }
}
