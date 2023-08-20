import Foundation

extension TimeInterval {
    var isTodayDate: Bool {
        return Calendar.current.isDateInToday(self.date)
    }

    var dateComponents: (Int, Int, Int) {
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: self.date)
        return (calendarDate.day ?? 0, calendarDate.month ?? 0, calendarDate.year ?? 0)
    }

    var date: Date {
        return Date(timeIntervalSince1970: self)
    }
}
