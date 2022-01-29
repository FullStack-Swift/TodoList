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

class TextField: UITextField {
  
  let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  
  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
  
  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
}
