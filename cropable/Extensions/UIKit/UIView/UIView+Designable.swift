import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var vBorderColor: UIColor {
        get {
            guard let color = layer.borderColor else { return .clear }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = newValue.cgColor }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            guard let shadowColor = layer.shadowColor else { return .clear }
            return UIColor(cgColor: shadowColor)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set {
            layer.shadowOffset = newValue
            
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContext(frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
    
    func bluredImage(radius:CGFloat = 1) -> UIImage {
        let image = snapshot()
        
        if let source = image?.cgImage {
            let context = CIContext(options: nil)
            let inputImage = CIImage(cgImage: source)
            
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter?.setDefaults()
            clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
            
            if let clampedImage = clampFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let filter = CIFilter(name: "CIGaussianBlur")
                filter?.setValue(clampedImage, forKey: kCIInputImageKey)
                filter?.setValue("\(radius)", forKey:kCIInputRadiusKey)
                
                if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
                   let cgImage = context.createCGImage(result, from: bounds) {
                    let returnImage = UIImage(cgImage: cgImage)
                    return returnImage
                }
            }
        }
        return UIImage()
    }
}

@objc extension UIView {
    
    func startSpinnerAnimation() {
        layer.addSublayer(CALayer.loadingLayer(with: frame))
    }
    
    func endSpinnerAnimation() {
        if let animationLayer = layer.sublayers?.first(where: { $0.name == "loading" }) {
            animationLayer.removeAllAnimations()
            animationLayer.removeFromSuperlayer()
        }
    }
}
