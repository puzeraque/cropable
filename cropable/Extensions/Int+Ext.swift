import Foundation

extension Int {
    var isEven: Bool { remainderReportingOverflow(dividingBy: 2).partialValue == 0 }
}

extension Int {
    func configureTimeText() -> String {
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self))
        let currentDate = Date()
        let calendar = Calendar.current
        
        if let year = calendar.dateComponents([.year], from: timestampDate).year, let currentYear = calendar.dateComponents([.year], from: currentDate).year {
            if year != currentYear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                return dateFormatter.string(from: timestampDate)
            } else if let month = calendar.dateComponents([.month], from: timestampDate).month, let currentMonth = calendar.dateComponents([.month], from: currentDate).month, month != currentMonth {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM"
                return dateFormatter.string(from: timestampDate)
                
            } else if let day = calendar.dateComponents([.day], from: timestampDate).day, let currentDay = calendar.dateComponents([.day], from: currentDate).day {
                
                if currentDay - day >= 7 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "d MMMM"
                    return dateFormatter.string(from: timestampDate)
                }
            }
        }
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        let string = formatter.localizedString(for: date, relativeTo: Date())
        if string == "через 0 секунд" {
            return "только что"
        }
        return string
    }

    func configureDayAndMonth() -> String {
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self))
        let currentDate = Date()
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: timestampDate)
    }

    func configureHoursAndMinutes() -> String {
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: timestampDate)
    }

    func configureFullDayDate() -> String {
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: timestampDate)
    }
}

extension Int {
    func configureMinutesAndSeconds() -> String {
        let minutes = self / 60
        let remainingSeconds = self % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
