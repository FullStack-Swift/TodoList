import UIKit
import OpenCombine

class BaseMainTableViewCell: UITableViewCell {
  
  var cancellables: Set<AnyCancellable> = []
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellables = []
  }
}
