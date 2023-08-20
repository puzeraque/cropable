import UIKit

final class PhotoSliperView: BaseView {
    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

    var onValueDidChange: ((CGFloat) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.scrollToItem(at: IndexPath(row: 50, section: 0), at: .left, animated: false)
    }

    override func setup() {
        super.setup()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        collectionView.register(
            PhotoSliderViewCell.self,
            forCellWithReuseIdentifier: "PhotoSliderViewCell"
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.backgroundColor = .clear
        collectionView.reloadData()
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(32)
            make.height.equalTo(24)
        }
    }
}

extension PhotoSliperView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSliderViewCell", for: indexPath) as? PhotoSliderViewCell else {
            return .init()

        }

        cell.configure(with: (indexPath.row % 10 == .zero))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 8, height: 24)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        findCenterIndex()
    }

    private func findCenterIndex() {
        let center = self.convert(self.collectionView.center, to: self.collectionView)
        guard let index = collectionView.indexPathForItem(at: center) else { return }
        onValueDidChange?(CGFloat(index.row) / 100)
        Vibration.heavy.vibrate()
    }
}
