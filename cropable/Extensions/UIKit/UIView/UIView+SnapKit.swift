import UIKit
import SnapKit

extension UIView {
    func edgesSuperview() {
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func edgesSuperviewWithInsets(
        top: CGFloat = .zero,
        bottom: CGFloat = .zero,
        left: CGFloat = .zero,
        right: CGFloat = .zero
    ) {
        snp.makeConstraints { make in
            make.top.equalToSuperview().inset(top)
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalToSuperview().inset(left)
            make.trailing.equalToSuperview().inset(right)
        }
    }

    func edgesSuperviewWithInset(inset: CGFloat) {
        snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(inset)
        }
    }

    func edgesSuperviewWithInsets(hInset: CGFloat = .zero, vInset: CGFloat = .zero) {
        snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(vInset)
            make.leading.trailing.equalToSuperview().inset(hInset)
        }
    }

    func addAndEdges(_ view: UIView) {
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func addAndEdgesViewWithInsets(
        _ view: UIView,
        top: CGFloat = .zero,
        bottom: CGFloat = .zero,
        left: CGFloat = .zero,
        right: CGFloat = .zero
    ) {
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(top)
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalToSuperview().inset(left)
            make.trailing.equalToSuperview().inset(right)
        }
    }

    func addAndEdgesViewWithInset(_ view: UIView, inset: CGFloat) {
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(inset)
        }
    }

    func addAndEdgesViewWithInsets(_ view: UIView, hInset: CGFloat = .zero, vInset: CGFloat = .zero) {
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(vInset)
            make.leading.trailing.equalToSuperview().inset(hInset)
        }
    }

    func addAndEdgesViewWithSafeAreaInsets(
        _ view: UIView,
        hInset: CGFloat = .zero,
        vInset: CGFloat = .zero
    ) {
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(vInset)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(vInset)
            make.leading.trailing.equalToSuperview().inset(hInset)
        }
    }

    func putInCenter(_ view: UIView) {
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func pinToTop(
        _ view: UIView,
        top: CGFloat = .zero,
        left: CGFloat = .zero,
        right: CGFloat = .zero
    ) {
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(top)
            make.leading.equalToSuperview().inset(left)
            make.trailing.equalToSuperview().inset(right)
        }
    }

    func size(_ size: CGSize) {
        snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
    }

    func height(_ size: CGFloat) {
        snp.remakeConstraints { make in
            make.height.equalTo(size)
        }
    }

    func width(_ size: CGFloat) {
        snp.remakeConstraints { make in
            make.width.equalTo(size)
        }
    }
}
