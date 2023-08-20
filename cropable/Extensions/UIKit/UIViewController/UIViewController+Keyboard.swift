import UIKit

extension UIViewController {

    func setupKeyboardNotifications(
        updateInsets: Bool = false,
        _ after: ((_ kbHeight: CGFloat) -> Void)? = nil
    ) {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil
        ) { (notification) in
            guard
                let userInfo = notification.userInfo,
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }

            if updateInsets {
                self.updateSafeAreaInsets(userInfo)
            }
            after?(keyboardFrame.minY < self.view.frame.maxY ? keyboardFrame.height : 0)
        }
    }

    func disableKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    func updateSafeAreaInsets(_ userInfo: [AnyHashable : Any]) {
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue else { return }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
            .insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: animationCurve,
            animations: { [weak self] in
                if let scrollView = self?.view.subviews.first as? UIScrollView {
                    scrollView.contentInset.bottom = intersection.height
                } else {
                    self?.additionalSafeAreaInsets.bottom = intersection.height
                }

                self?.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delaysTouchesBegan = true
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
