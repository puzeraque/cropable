import UIKit

protocol Blurable {
    var layer: CALayer { get }
    var subviews: [UIView] { get }
    var frame: CGRect { get }
    var superview: UIView? { get }
    
    func addSubview(_ view: UIView)
    func removeFromSuperview()
    
    func blur(blurRadius: CGFloat)
    func unBlur()
    
    var isBlurred: Bool { get }
}

extension Blurable {
    func blur(blurRadius: CGFloat) {
        guard self.superview != nil else { return }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        guard
            let blur = CIFilter(name: "CIGaussianBlur"),
            let this = self as? UIView,
            let image = image else
        { return }
        
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        let boundingRect = CGRect(
            x:0,
            y: 0,
            width: frame.width,
            height: frame.height
        )
        
        guard
            let result = blur.value(forKey: kCIOutputImageKey) as? CIImage,
            let cgImage = ciContext.createCGImage(result.clamped(to: boundingRect), from: boundingRect)
        else { return }
        
        let filteredImage = UIImage(cgImage: cgImage)
        
        let overlayContainerView = UIView()
        overlayContainerView.translatesAutoresizingMaskIntoConstraints = false
        overlayContainerView.backgroundColor = .clear
        
        superview?.addSubview(overlayContainerView)
        
        overlayContainerView.leadingAnchor.constraint(equalTo: superview!.leadingAnchor).isActive = true
        overlayContainerView.trailingAnchor.constraint(equalTo: superview!.trailingAnchor).isActive = true
        overlayContainerView.topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        overlayContainerView.bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
        
        let darkOverlay = UIView()
        darkOverlay.translatesAutoresizingMaskIntoConstraints = false
        darkOverlay.backgroundColor = .black.withAlphaComponent(0.3)
        
        overlayContainerView.addSubview(darkOverlay)
        
        darkOverlay.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor).isActive = true
        darkOverlay.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor).isActive = true
        darkOverlay.topAnchor.constraint(equalTo: overlayContainerView.topAnchor).isActive = true
        darkOverlay.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor).isActive = true
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = .scaleAspectFill
        blurOverlay.clipsToBounds = (self as? UIView)?.clipsToBounds ?? false
        blurOverlay.layer.cornerRadius = (self as? UIView)?.cornerRadius ?? 0
        
        //        if let superview = superview as? UIStackView,
        //           let index = (superview as UIStackView).arrangedSubviews.firstIndex(of: this)
        //        {
        //            removeFromSuperview()
        //            superview.insertArrangedSubview(blurOverlay, at: index)
        //        }
        //        else
        //        {
        overlayContainerView.addSubview(blurOverlay)
        blurOverlay.translatesAutoresizingMaskIntoConstraints = false
        blurOverlay.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor).isActive = true
        blurOverlay.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor).isActive = true
        blurOverlay.topAnchor.constraint(equalTo: overlayContainerView.topAnchor).isActive = true
        blurOverlay.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor).isActive = true
        
        //            blurOverlay.frame.origin = frame.origin
        
        //            UIView.transition(from: this,
        //                              to: blurOverlay,
        //                duration: 0.2,
        //                options: .curveEaseIn,
        //                completion: nil)
        //        }
        
        objc_setAssociatedObject(
            this,
            &BlurableKey.blurable,
            blurOverlay,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        )
    }
    
    func unBlur() {
        guard
            let this = self as? UIView,
            let blurOverlay = objc_getAssociatedObject(self, &BlurableKey.blurable) as? BlurOverlay
        else { return }
        
        //        if let superview = blurOverlay.superview as? UIStackView,
        //           let index = (blurOverlay.superview as! UIStackView).arrangedSubviews.firstIndex(of: blurOverlay)
        //        {
        //            blurOverlay.removeFromSuperview()
        //            superview.insertArrangedSubview(this, at: index)
        //        }
        //        else
        //        {
        blurOverlay.superview?.removeFromSuperview()
        //            this.frame.origin = blurOverlay.frame.origin
        //
        //            UIView.transition(from: blurOverlay,
        //                              to: this,
        //                duration: 0.2,
        //                options: .curveEaseIn,
        //                completion: nil)
        //        }
        
        objc_setAssociatedObject(
            this,
            &BlurableKey.blurable,
            nil,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        )
    }
    
    var isBlurred: Bool {
        return objc_getAssociatedObject(self, &BlurableKey.blurable) is BlurOverlay
    }
}

extension UIView: Blurable { }

class BlurOverlay: UIImageView { }

enum BlurableKey {
    static var blurable = "blurable"
}
