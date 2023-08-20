import Foundation

extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }
}

extension String {
    static let empty = ""
}
