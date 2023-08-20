import UIKit

extension UITableView {

    func scrollByIndexToBottom(animated: Bool = false) {
        guard numberOfSections != 0 else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }

    func scrollByIndexToTop(animated: Bool = true) {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: .zero, section: .zero)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: animated)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections
        && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
