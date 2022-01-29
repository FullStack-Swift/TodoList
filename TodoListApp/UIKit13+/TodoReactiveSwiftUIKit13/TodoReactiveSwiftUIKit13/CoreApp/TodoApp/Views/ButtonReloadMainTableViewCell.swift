import UIKit
import ReactiveSwift
import ReactiveCocoa

class ButtonReloadMainTableViewCell: UITableViewCell {
  
  let buttonReload = UIButton(type: .system)
  let networkStatus = UILabel()
  let activityIndicator = UIActivityIndicatorView()
  var disposables = CompositeDisposable()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposables.dispose()
    disposables = CompositeDisposable()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.isUserInteractionEnabled = false
    // buttonReload
    buttonReload.setTitle("Reload", for: .normal)
    buttonReload.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    buttonReload.setTitleColor(.black, for: .normal)
    buttonReload.translatesAutoresizingMaskIntoConstraints = false
    addSubview(buttonReload)
    NSLayoutConstraint.activate([
      buttonReload.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonReload.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
    // networkStatus
    networkStatus.text = ""
    networkStatus.translatesAutoresizingMaskIntoConstraints = false
    networkStatus.font = UIFont.boldSystemFont(ofSize: 15)
    addSubview(networkStatus)
    NSLayoutConstraint.activate([
      networkStatus.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      networkStatus.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
    ])
    // activityIndicator
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
