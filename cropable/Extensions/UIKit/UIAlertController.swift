import UIKit

extension UIAlertController {

    class func showErrorAlert(_ error: LocalizedError, from: UIViewController) {
        showAlert("Ошибка", message: error.errorDescription, from: from)
    }

    class func showAlert(
        _ title: String,
        message: String?,
        from: UIViewController,
        showsCancel: Bool = false,
        buttonTitle: String = "OK",
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: buttonTitle,
                style: .default,
                handler: { _ in
                    completion?()
                }
            )
        )
        if showsCancel {
            alert.addAction(
                .init(
                    title: "Cancel",
                    style: .cancel,
                    handler: { _ in

                    }
                )
            )
        }
        from.present(alert, animated: true, completion: nil)
    }
}
