import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
  
  var disposeBag = DisposeBag()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
}
