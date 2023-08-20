import UIKit

extension UIButton {
    func setTintColor(_ color: UIColor, for state: UIControl.State) {
        setImage(currentImage?.withTintColor(color), for: state)
    }
}
