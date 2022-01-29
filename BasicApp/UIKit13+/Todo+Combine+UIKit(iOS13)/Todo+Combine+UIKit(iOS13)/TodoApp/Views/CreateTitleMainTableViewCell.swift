import UIKit
import Combine

class CreateTitleMainTableViewCell: UITableViewCell {
  
  let buttonCreate = UIButton(type: .system)
  let textFieldTitle = UITextField()
  
  var cancellables: Set<AnyCancellable> = []
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellables = []
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.isUserInteractionEnabled = false
    buttonCreate.setTitle("Create", for: .normal)
    buttonCreate.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    buttonCreate.setTitleColor(.blue, for: .normal)
    buttonCreate.translatesAutoresizingMaskIntoConstraints = false
    
    textFieldTitle.placeholder = "title"
    let rootStackView = UIStackView(arrangedSubviews: [
      textFieldTitle,
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

