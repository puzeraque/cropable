import UIKit

class BaseBottomSheetView: UIView {
    
    /// Необходимо указать высоту объекта ContentView
    open var heightOfPresentationView: CGFloat {
        return 0
    }
    /// Минимальная высота необходимая для отображения ContentView
    let minimumHaight: CGFloat = 60
    
    /// Определить cornerRadius для ContentView. По умолчанию 20
    open var containerViewCornerRadius: CGFloat {
        return 20
    }
    
    private let headerElement : UIView = {
        let headerElement = UIView()
        headerElement.translatesAutoresizingMaskIntoConstraints = false
        headerElement.backgroundColor = UIColor(red: 0.792, green: 0.8, blue: 0.812, alpha: 1)
        headerElement.layer.cornerRadius = 2
        return headerElement
    }()
    
    ///  Необходимо отдельно  добавить при инициализации и установить констрейнты по границам экрана
    let fadeView: UIView = {
        let fadeView = UIView(frame: .zero)
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fadeView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        fadeView.isHidden = true
        return fadeView
    }()
    
    /// Добавляется снизу экрана где contentView.topAncore == view.bottomAncore
    /// leading и trealing установить по ширине экрана
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        return contentView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func commonInit() {
        setupViews()
        contentView.layer.cornerRadius = containerViewCornerRadius
         let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissController))
         swipeDownGesture.direction = .down
         contentView.addGestureRecognizer(swipeDownGesture)
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
         fadeView.addGestureRecognizer(tapGesture)
    }
    
     func setupViews() {
        addSubview(fadeView)
        addSubview(contentView)
        contentView.addSubview(headerElement)
        
        NSLayoutConstraint.activate([
            fadeView.topAnchor.constraint(equalTo: topAnchor),
            fadeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            fadeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fadeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: heightOfPresentationView + 60),
            
            headerElement.widthAnchor.constraint(equalToConstant: 45),
            headerElement.heightAnchor.constraint(equalToConstant: 4),
            headerElement.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerElement.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        ])
    }
}
// MARK: - Animation of presentation and dismiss
 extension BaseBottomSheetView {
   
     /// Animate of presentation self contentView
     func presentController() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) { [weak self] in
                guard let self = self else { return }
                self.fadeView.isHidden = false
                self.contentView.transform = CGAffineTransform(translationX: 0, y: -self.heightOfPresentationView + 10)
            }
        }
    }
     /// Animate of dismiss self contentView
     @objc func dismissController() {
         DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.11) {
             UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn]) { [weak self] in
                 self?.contentView.transform = CGAffineTransform.identity
             } completion: { [weak self] _ in
                 self?.fadeView.isHidden = true
             }
         }
     }
    
}
