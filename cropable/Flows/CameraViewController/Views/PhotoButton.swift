import UIKit

final class PhotoButton: BaseButton {
    private let baseView = BaseView()

    override func layoutSubviews() {
        super.layoutSubviews()
        drawGradientColor(colors: [UIColor.gray.cgColor, UIColor.darkGray.cgColor])
        baseView.drawGradientColor(colors: [UIColor.lightGray.cgColor, UIColor.white.cgColor])
    }

    override func setup() {
        super.setup()
        cornerRadius = 36
        clipsToBounds = true

        addSubview(baseView)
        baseView.cornerRadius = 20
        baseView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.square(40))
        }
    }
}
