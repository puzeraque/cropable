import UIKit
import CoreML
import Vision

class CropImageHelper {
    private let mlModelConfiguration = MLModelConfiguration()
    private lazy var model = try? VNCoreMLModel(for: DeepLabV3(configuration: mlModelConfiguration).model)

    private var outputImage: UIImage?
    private let image: UIImage?

    var onImageCompleted: ((UIImage?) -> Void)?

    init(image: UIImage?) {
        self.image = image
    }

    func start() {
        segmentImage()
    }

    private func segmentImage() {
        guard
            let model = model,
            let image = image?.resizeImage(targetSize: UIScreen.main.bounds.size),
            let ciImage = CIImage(image: image)
        else { return }

        var request: VNCoreMLRequest
        request = VNCoreMLRequest(
            model: model,
            completionHandler: visionRequestDidComplete(request:error:)
        )
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(ciImage: ciImage)

        DispatchQueue.global().async {
            do {
                try? handler.perform([request])
            }
        }
    }

    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let image = self.image else { return }
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationMap = observations.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationMap.image(min: 0, max: 1)

                self.outputImage = segmentationMask?.resized(to: image.size)
                self.outputImage = self.maskInputImage()
                self.onImageCompleted?(self.outputImage)
            }
        }
    }


    private func maskInputImage() -> UIImage? {
        guard
            let image = self.image,
            let cgImage = image.cgImage,
            let bgImage = UIImage.imageFromColor(color: .clear, size: UIScreen.main.bounds.size, scale: image.scale),
            let bgImageCgImage = bgImage.cgImage,
            let outputImage = self.outputImage,
            let outputImageCgImage = outputImage.cgImage
        else { return nil }

        let beginImage = CIImage(cgImage: cgImage)
        let background = CIImage(cgImage: bgImageCgImage)
        let mask = CIImage(cgImage: outputImageCgImage)

        if let compositeImage = CIFilter(
            name: "CIBlendWithMask",
            parameters: [
                kCIInputImageKey: background,
                kCIInputBackgroundImageKey: beginImage,
                kCIInputMaskImageKey: mask
            ]
        )?.outputImage {
            let ciContext = CIContext()
            guard let filteredImageReference = ciContext.createCGImage(
                compositeImage,
                from: compositeImage.extent
            ) else { return nil }
            return UIImage(cgImage: filteredImageReference)
        }

        return UIImage()
    }
}

extension UIImage {
    class func imageFromColor(
        color: UIColor,
        size: CGSize = CGSize(width: 1, height: 1),
        scale: CGFloat
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    func resizeImageData() -> Data? {
        var actualHeight: Float = Float(size.height)
        var actualWidth: Float = Float(size.width)
        let maxHeight: Float = 1280.0
        let maxWidth: Float = 1280.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.8
        //50 percent compression

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        let imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return imageData
    }

    func cropImageToAspectRatio(aspectRatio: CGFloat) -> UIImage? {
        let imageWidth = size.width
        let imageHeight = size.height

        var targetWidth: CGFloat = 0.0
        var targetHeight: CGFloat = 0.0

        if aspectRatio == 1.0 {
            // Если aspectRatio равен 1:1, то подгоняем изображение к квадрату
            if imageWidth > imageHeight {
                targetWidth = imageHeight
                targetHeight = imageHeight
            } else {
                targetWidth = imageWidth
                targetHeight = imageWidth
            }
        } else if aspectRatio == 4.0 / 5.0 {
            // Если aspectRatio равен 4:5, то подгоняем изображение к прямоугольнику с соотношением сторон 4:5
            let targetRatio = 4.0 / 5.0
            let imageRatio = imageWidth / imageHeight

            if imageRatio > targetRatio {
                targetHeight = imageHeight
                targetWidth = targetHeight * targetRatio
            } else {
                targetWidth = imageWidth
                targetHeight = targetWidth / targetRatio
            }
        }

        let x = (imageWidth - targetWidth) / 2.0
        let y = (imageHeight - targetHeight) / 2.0

        let targetRect = CGRect(x: x, y: y, width: targetWidth, height: targetHeight)

        if let cgImage = cgImage?.cropping(to: targetRect) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }

        return nil
    }

    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
