import Foundation

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) г"   }
        if months(from: date)  > 0 { return "\(months(from: date)) мес"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) нед"   }
        if days(from: date)    > 0 { return "\(days(from: date)) дн"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) ч"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) мин" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) сек" }
        return ""
    }

    func isEqualDays(with date: Date) -> Bool {
        let years = years(from: date)
        let months = months(from: date)
        let days = days(from: date)

        return years == 0 && months == 0 && days == 0
    }
}
