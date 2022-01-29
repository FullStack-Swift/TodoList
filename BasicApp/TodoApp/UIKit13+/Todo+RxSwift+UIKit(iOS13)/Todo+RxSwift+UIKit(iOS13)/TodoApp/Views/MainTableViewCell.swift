import UIKit
import RxSwift

class MainTableViewCell: UITableViewCell {
  
  let circleView = UIView()
  let titleView = UILabel()
  let deleteButton = UIButton(type: .system)
  let tapGesture = UITapGestureRecognizer()
  
  private(set) var disposeBag = DisposeBag()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    circleView.layer.cornerRadius = 10
    contentView.isUserInteractionEnabled = false
    addGestureRecognizer(tapGesture)
    deleteButton.setTitle("Delete", for: .normal)
    deleteButton.setTitleColor(.gray, for: .normal)
    let rootStackView = UIStackView(arrangedSubviews: [
      circleView,
      titleView,
      deleteButton,
    ])
    
    circleView.translatesAutoresizingMaskIntoConstraints = false
    circleView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    circleView.widthAnchor.constraint(equalToConstant: 20).isActive = true
    rootStackView.alignment = .center
    rootStackView.spacing = 10
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
  
  func bind(_ data: Any) {
    guard let data = data as? Todo else {
      return
    }
    circleView.backgroundColor = data.isCompleted ? UIColor.green : UIColor.red
    titleView.text = data.title
    
  }
  
}
