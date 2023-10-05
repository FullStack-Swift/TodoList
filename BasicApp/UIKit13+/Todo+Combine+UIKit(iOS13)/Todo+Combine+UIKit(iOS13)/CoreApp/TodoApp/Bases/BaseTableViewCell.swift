import UIKit
import Combine

class BaseTableViewCell: UITableViewCell {
  
  var cancellables: Set<AnyCancellable> = []
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellables = []
  }
}
