import UIKit

extension UIScreen {
    var hasNotch: Bool {
        if #available(iOS 11.0, *),
           UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0 {
            return true
        }
        return false
    }

    var topPadding: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }

    var bottomPadding: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }

    var heightWithoutPadding: CGFloat {
        return ((UIApplication.shared.keyWindow?.bounds.height ?? 0) - topPadding - bottomPadding)
    }
}
