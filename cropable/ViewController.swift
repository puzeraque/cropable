import UIKit
import SnapKit
import AVFoundation

class ViewController: UIViewController {

    private let image = UIImageView()
    private let helper = CropImageHelper(image: UIImage(named: "photo"))
    private let previewView = UIView()
    private let photoButton = UIButton()

    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var movieOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var captureDevice: AVCaptureDevice?
    private var finalImage: UIImage?

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
        view.addSubview(photoButton)

        photoButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 72))
        }

        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(photoButton.snp.top).inset(-32)
        }
        previewView.layer.cornerRadius = 10
        previewView.clipsToBounds = true
        previewView.addSubview(image)
        image.contentMode = .scaleAspectFill
        image.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.bringSubviewToFront(photoButton)
        photoButton.backgroundColor = .black
        photoButton.layer.cornerRadius = 36

        helper.start()
        helper.onImageCompleted = { image in
            self.image.image = image
            self.image.alpha = 1
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
}
