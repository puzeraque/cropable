import UIKit

final class PhotoSliderViewCell: BaseCollectionViewCell {
    private let baseView = BaseView()

    override func setup() {
        super.setup()
        baseView.backgroundColor = .gray
        baseView.cornerRadius = 1
        let stackView = UIStackView(arrangedSubviews: [BaseView(), baseView])
        stackView.axis = .vertical
        addAndEdgesViewWithInsets(stackView, hInset: 3)
    }
}

extension PhotoSliderViewCell: Configurable {
    typealias Model = Bool

    func configure(with model: Bool) {
        baseView.height(model ? 24 : 18)
    }
}
