import QuartzCore
import UIKit

extension CALayer {
    class func loadingLayer(with frame: CGRect) -> CALayer {
        let spinnerSize: CGFloat = 16
        
        let center = CGPoint(
            x: frame.width / 2 - spinnerSize / 2,
            y: frame.height / 2 - spinnerSize / 2
        )
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let circle = CAShapeLayer()
        circle.name = "loading"
        
        let path = UIBezierPath()

        path.addArc(
            withCenter: CGPoint(x: spinnerSize / 2, y: spinnerSize / 2),
            radius: spinnerSize / 2,
            startAngle: -(.pi / 2),
            endAngle: .pi + .pi / 2,
            clockwise: true
        )
        circle.fillColor = nil
        circle.strokeColor = UIColor.white.cgColor
        circle.lineWidth = 2
        circle.backgroundColor = nil
        circle.path = path.cgPath
        circle.frame = CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize)
        
        
        let frame = CGRect(
            x: center.x,
            y: center.y,
            width: spinnerSize,
            height: spinnerSize
        )
        
        circle.frame = frame
        circle.add(groupAnimation, forKey: "animation")
        
        return circle
    }
}

extension CALayer {
  @discardableResult
  func animateScale(from fromValue: CGFloat, to toValue: CGFloat, duration: Double, removeOnCompletion: Bool) -> CABasicAnimation {
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
    scaleAnimation.fromValue = fromValue
    scaleAnimation.toValue = toValue
    scaleAnimation.duration = duration
    scaleAnimation.repeatCount = .infinity
    scaleAnimation.isRemovedOnCompletion = removeOnCompletion
    scaleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
    return scaleAnimation
  }
}
