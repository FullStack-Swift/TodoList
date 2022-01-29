import UIKit
import SwiftUI
import ReactiveSwift
import ReactiveCocoa

class CreateTitleMainTableViewCell: UITableViewCell {
  
  let buttonCreate = UIButton(type: .system)
  let titleTextField = UITextField()
  
  var disposables = CompositeDisposable()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposables.dispose()
    disposables = CompositeDisposable()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.isUserInteractionEnabled = false
    buttonCreate.setTitle("Create", for: .normal)
    buttonCreate.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    buttonCreate.setTitleColor(UIColor(Color.green), for: .normal)
    buttonCreate.translatesAutoresizingMaskIntoConstraints = false
    
    titleTextField.placeholder = "title"
    let rootStackView = UIStackView(arrangedSubviews: [
      titleTextField,
      buttonCreate,
    ])
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(rootStackView)
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: topAnchor),
      rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

