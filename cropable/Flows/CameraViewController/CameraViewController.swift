import UIKit
import SnapKit
import AVFoundation

class CameraViewController: UIViewController {

    private let imageView = UIImageView()
    private let helper = CropImageHelper(image: UIImage(named: "photo"))
    private let previewView = UIView()
    private let additionalToolsView = CameraAdditionalToolsView()
    private let alphaView = PhotoSliperView()
    private let photoButton = PhotoButton()

    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var movieOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var captureDevice: AVCaptureDevice?
    private var finalImage: UIImage?
    private var firstImage: UIImage?

    private var zoomFactor: Float = 1.0

    private var isOpen = false

    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized

            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }

            return isAuthorized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
              if response {
                  //access granted
              } else {

              }
          }
        setupSession()
        setupLivePreview()

        view.addSubview(alphaView)

        alphaView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(24)
        }

        alphaView.onValueDidChange = { alpha in
            self.imageView.alpha = alpha
        }

        view.addSubview(photoButton)

        photoButton.snp.makeConstraints { make in
            make.bottom.equalTo(alphaView.snp.top).inset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 72))
        }

        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(photoButton.snp.top).inset(-20)
        }
        previewView.addGestureRecognizer(
            UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
        )
        previewView.layer.cornerRadius = 10
        previewView.clipsToBounds = true
        previewView.addSubview(imageView)
        imageView.alpha = 0.4
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.bringSubviewToFront(photoButton)

//        helper.start()
//        helper.onImageCompleted = { image in
//            self.image.image = image
//            self.image.alpha = 1
//        }

        view.addSubview(additionalToolsView)

        additionalToolsView.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalToSuperview().inset(-44)
            make.height.equalTo(view.snp.width).inset(72)
        }

        addReplyAction()

        imageView.image = UIImage(named: "photo")
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)

        imageView.addTapGesture {
            guard self.isOpen else { return }
            self.additionalToolsView.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(-44)
            }
            self.isOpen = false
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer.frame = previewView.bounds
    }

    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard
            let backCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: AVMediaType.video,
                position: .back
            )
        else {
            print("Unable to access front camera!")
            return
        }
        captureDevice = backCamera

        do {
            captureDevice?.isFocusModeSupported(.continuousAutoFocus)
            guard let captureDevice = captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput.isHighResolutionCaptureEnabled = true
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                let connection = stillImageOutput.connection(with: AVMediaType.video)
                if captureDevice.position == .front,
                   (connection?.isVideoMirroringSupported)! {
                    connection?.automaticallyAdjustsVideoMirroring = false
                    connection?.isVideoMirrored = true
                }
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @objc
    private func pinchToZoom(_ pinch: UIPinchGestureRecognizer) {
        let newScaleFactor = minMaxZoom(pinch.scale * CGFloat(zoomFactor))

        switch pinch.state {
        case .began:
            fallthrough
        case .changed:
            update(scale: newScaleFactor)
        case .ended:
            zoomFactor = Float(minMaxZoom(newScaleFactor))
            update(scale: CGFloat(zoomFactor))
        default:
            break
        }
    }

    private func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        guard let device = captureDevice else { return 1 }
        return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
    }

    private func update(scale factor: CGFloat) {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.videoZoomFactor = factor
        } catch {
            debugPrint(error)
        }
    }

    @objc
    private func photoTapped() {
        let photoSettings: AVCapturePhotoSettings
        if stillImageOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        } else {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    private func addReplyAction() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureCellAction))
        panGestureRecognizer.delaysTouchesBegan = true
        additionalToolsView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func panGestureCellAction(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let x = recognizer.view?.frame.origin.x ?? .zero
        switch recognizer.state {
        case .began, .changed:
            if isOpen {
                guard translation.x < 0, x > -44 else {
                    return
                }
                recognizer.view?.center = CGPoint(
                    x: (recognizer.view?.center.x ?? .zero) + translation.x,
                    y: (recognizer.view?.center.y ?? .zero)
                )
                recognizer.setTranslation(.zero, in: self.view)
            } else {
                guard x < 16 else {
                    return
                }
                recognizer.view?.center = CGPoint(
                    x: (recognizer.view?.center.x ?? .zero) + translation.x,
                    y: (recognizer.view?.center.y ?? .zero)
                )
                recognizer.setTranslation(.zero, in: self.view)
            }
        default:
            if isOpen {
                additionalToolsView.snp.updateConstraints { make in
                    make.leading.equalToSuperview().inset(-44)
                }
                isOpen = false
            } else {
                additionalToolsView.snp.updateConstraints { make in
                    make.leading.equalToSuperview().inset(20)
                }
                isOpen = true
            }

            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                let imageData = photo.fileDataRepresentation(),
                let image = UIImage(data: imageData)
            else { return }
            guard firstImage == nil else {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                return
            }
            finalImage = image
            self.imageView.image = image
        }
    }
}

enum CameraAdditionalToolType: CaseIterable {
    case flash
    case contrast
    case changeCamera

    var image: UIImage? {
        switch self {
        case .flash:
            return UIImage(named: "flash_fill")
        case .changeCamera:
            return UIImage(named: "refresh")
        case .contrast:
            return UIImage(named: "contrast")
        }
    }
}

final class CameraAdditionalToolsView: BaseView {
    private let blurEffest = UIBlurEffect(style: .systemUltraThinMaterialDark)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffest)

    var onToolSelected: ((CameraAdditionalToolType) -> Void)?

    override func setup() {
        cornerRadius = 20
        clipsToBounds = true
        addAndEdges(blurEffectView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        CameraAdditionalToolType.allCases.forEach { type in
            let imageView = UIImageView(image: type.image)
            imageView.tintColor = .black
            imageView.size(.square(24))
            imageView.addTapGesture { [weak self] in
                self?.onToolSelected?(type)
            }
            stackView.addArrangedSubview(imageView)
        }

        addAndEdgesViewWithInsets(stackView, hInset: 20, vInset: 32)
    }
}
