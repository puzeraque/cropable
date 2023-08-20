import UIKit

extension UIScrollView {
    func scrollToBottom(animated: Bool = false) {
        let bottomOffset = CGPoint(
            x: .zero,
            y: contentSize.height - bounds.height + contentInset.bottom
        )
        setContentOffset(bottomOffset, animated: animated)
    }

    func scrollToTop(animated: Bool = false) {
        setContentOffset(.zero, animated: animated)
    }
}
