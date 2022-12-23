import UIKit
import SwiftUI

extension UITableViewCell {
  static var withIdentifier: String {
    String(describing: Self.self)
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

public struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
  public let makeUIView: (Context) -> UIViewType
  public let updateUIView: (UIViewType, Context) -> Void = { _, _ in }
  
  public init(makeUIView: @escaping (Context) -> UIViewType) {
    self.makeUIView = makeUIView
  }
  
  public func makeUIView(context: Context) -> UIViewType {
    self.makeUIView(context)
  }
  
  public func updateUIView(_ uiView: UIViewType, context: Context) {
    self.updateUIView(uiView, context)
  }
}

extension UIView {
  func toSwifUIView() -> UIViewRepresented<UIView> {
    UIViewRepresented(
      makeUIView: { _ in self }
    )
  }
}

extension UIViewController {
  func toSwifUIView() -> UIViewRepresented<UIView> {
    UIViewRepresented(
      makeUIView: { _ in self.view }
    )
  }
}

open class PaddingTextField: UITextField {
  
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
