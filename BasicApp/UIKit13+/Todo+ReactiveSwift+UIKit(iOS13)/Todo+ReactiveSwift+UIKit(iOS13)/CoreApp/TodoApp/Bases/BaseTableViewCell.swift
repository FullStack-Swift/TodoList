import UIKit
import ReactiveSwift

class BaseTableViewCell: UITableViewCell {
  
  private(set) var disposables = CompositeDisposable()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposables.dispose()
    disposables = CompositeDisposable()
  }
}
