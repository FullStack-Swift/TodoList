import UIKit

final class ActivityIndicatorViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
      // setupview
    if #available(iOS 13.0, *) {
      self.view.backgroundColor = .systemBackground
    } else {
        // Fallback on earlier versions
    }
      // activityIndicator
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
    ])
  }
}
