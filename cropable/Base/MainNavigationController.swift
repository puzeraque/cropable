import UIKit

class MainNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        view.backgroundColor = .white
        setupNavigationAppearance()
    }
}

extension UINavigationController {
    func setupNavigationAppearance(additionalTopInset: CGFloat = 13) {
        navigationBar.isTranslucent = true
        let arrowImage = UIImage(named: "arrowLeft")
        self.additionalSafeAreaInsets.top = additionalTopInset
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear

        let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "SFProText-Semibold", size: 17) ?? .systemFont(ofSize: 17)
        ]
        appearance.titlePositionAdjustment = UIOffset(horizontal: .zero, vertical: .zero)
        appearance.buttonAppearance = buttonAppearance
        appearance.setBackIndicatorImage(arrowImage, transitionMaskImage: arrowImage)
        appearance.backgroundColor = .white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance

        navigationBar.tintColor = UIColor.black
        if #available(iOS 14.0, *) {
            navigationBar.topItem?.backButtonDisplayMode = .minimal
            navigationItem.backButtonDisplayMode = .minimal
        } else {
            // Fallback on earlier versions
        }
        edgesForExtendedLayout = []

        setNavigationBarHidden(false, animated: true)
    }
}
