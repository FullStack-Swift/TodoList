import UIKit

extension UITableViewCell {
  static var withIdentifier: String {
    return String(describing: Self.self)
  }
}

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
    dequeueReusableCell(withIdentifier: type.withIdentifier, for: indexPath) as! T
  }
  
  func register<T: UITableViewCell>(_ type: T.Type) {
    register(type, forCellReuseIdentifier: type.withIdentifier)
  }
}
