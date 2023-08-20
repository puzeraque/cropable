import UIKit

class BaseView: UIView {

    private var onTapped: VoidHandler?
    private var onTappedWithPosition: ((CGPoint) -> Void)?

    init(backgroundColor: UIColor? = nil) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.cancelsTouchesInView = true
        addGestureRecognizer(tap)
    }

    @objc private func tapped(gesture: UITapGestureRecognizer) {
        onTapped?()

        let location = gesture.location(in: superview)
        onTappedWithPosition?(location)
    }

    func onTap(_ completion: @escaping VoidHandler) {
        self.onTapped = completion
    }

    func onTapWithPosition(_ completion: @escaping ((CGPoint) -> Void)) {
        self.onTappedWithPosition = completion
    }

    func fadeIn(duration: TimeInterval? = 0.2,
                delay: TimeInterval = .zero,
                then: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration ?? .zero,
                       delay: delay,
                       animations: alphaAnimation(to: 1),
                       completion: wrapped(completion: then))
    }

    func fadeOut(duration: TimeInterval? = 0.2,
                 delay: TimeInterval = .zero,
                 then: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration ?? .zero,
                       delay: delay,
                       animations: alphaAnimation(to: .zero),
                       completion: wrapped(completion: then))
    }

    private func wrapped(completion: (() -> Void)?) -> ((Bool) -> Void)? {
        guard let completion = completion else {
            return nil
        }
        return { _ in
            completion()
        }
    }

    private func alphaAnimation(to alpha: CGFloat) -> () -> Void {
        return { [weak self] in
            self?.alpha = alpha
        }
    }
}

extension BaseView {
    func drawGradientColor(colors: [CGColor]) {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: nil
            )
        else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width / 2, y: 0),
            end: CGPoint(x: size.width / 2, y: size.height),
            options: []
        )
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else {
            return
        }
        self.backgroundColor = UIColor(patternImage: image)
    }
}

import UIKit

class BaseButton: UIButton {

    private var onTapped: VoidHandler?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() { }

    func drawGradientColor(colors: [CGColor]) {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: nil
            )
        else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width / 2, y: 0),
            end: CGPoint(x: size.width / 2, y: size.height),
            options: []
        )
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else {
            return
        }
        self.backgroundColor = UIColor(patternImage: image)
    }
}
