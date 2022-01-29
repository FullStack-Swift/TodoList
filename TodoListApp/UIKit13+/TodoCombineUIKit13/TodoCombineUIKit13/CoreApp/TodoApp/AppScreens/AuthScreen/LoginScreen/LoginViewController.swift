import ComposableArchitecture
import Combine
import SwiftUI
import UIKit

final class LoginViewController: UIViewController {
  
  private let store: Store<LoginState, LoginAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private var cancellables: Set<AnyCancellable> = []
  
  init(store: Store<LoginState, LoginAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: LoginState(), reducer: LoginReducer, environment: LoginEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: LoginAction.init))
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
    view.backgroundColor = .white
      // title
    let titleLogin = UILabel()
    titleLogin.text = "Login"
    titleLogin.font = UIFont.boldSystemFont(ofSize: 30)
    titleLogin.textAlignment = .left
    titleLogin.translatesAutoresizingMaskIntoConstraints = false
      // emailTextField
    let emailTextField = TextField()
    emailTextField.placeholder = "email"
    emailTextField.backgroundColor = UIColor(Color.gray.opacity(0.1))
      // passwordTextField
    let passwordTextField = TextField()
    passwordTextField.isSecureTextEntry = true
    passwordTextField.placeholder = "password"
    passwordTextField.backgroundColor = UIColor(Color.gray.opacity(0.1))
      // buttonLogin
    let buttonLogin = UIButton(type: .system)
    buttonLogin.setTitle("Login", for: .normal)
    buttonLogin.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    buttonLogin.setTitleColor(UIColor(Color.blue), for: .normal)
    buttonLogin.translatesAutoresizingMaskIntoConstraints = false
    buttonLogin.backgroundColor = UIColor(Color.blue)
    buttonLogin.setTitleColor(UIColor(Color.white), for: .normal)
      /// containerView
    let rootStackView = UIStackView(arrangedSubviews: [
      titleLogin,
      emailTextField,
      passwordTextField,
      buttonLogin
    ])
    rootStackView.axis = .vertical
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    rootStackView.alignment = .leading
    rootStackView.spacing = 10
    rootStackView.distribution = .fillProportionally
    view.addSubview(rootStackView)
    
    // Constraint
    NSLayoutConstraint.activate([
      // rootStackView
      rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      rootStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 10),
      rootStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
      // title
      titleLogin.heightAnchor.constraint(equalToConstant: 50),
      titleLogin.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      titleLogin.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // passwordTextField
      emailTextField.heightAnchor.constraint(equalToConstant: 50),
      emailTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      emailTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // passwordTextField
      passwordTextField.heightAnchor.constraint(equalToConstant: 50),
      passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      passwordTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // buttonLogin
      buttonLogin.heightAnchor.constraint(equalToConstant: 52),
      buttonLogin.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      buttonLogin.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
    ])
    
      //bind view to viewstore
    buttonLogin.tapPublisher
      .map{ViewAction.login}
      .subscribe(viewStore.action)
      .store(in: &cancellables)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.viewWillAppear)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.viewWillDisappear)
  }
}

struct LoginViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = LoginViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
  }
}

fileprivate struct ViewState: Equatable {
  init(state: LoginState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case login
  init(action: LoginAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    default:
      self = .none
    }
  }
}

fileprivate extension LoginAction {
  init(action: ViewAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    case .login:
      self = .loginSuccess
    default:
      self = .none
    }
  }
}
