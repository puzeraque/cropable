import UIKit

extension UIScreen {
    func heightForPhone(_ value: CGFloat) -> CGFloat {
        return bounds.height * value / 812
    }

    func widthForPhone(_ value: CGFloat) -> CGFloat {
        return bounds.width * value / 375
    }
}
