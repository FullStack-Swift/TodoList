import ComposableArchitecture
import Combine
import SwiftUI
import UIKit

final class RegisterViewController: UIViewController {
  
  private let store: Store<RegisterState, RegisterAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private var cancellables: Set<AnyCancellable> = []
  
  init(store: Store<RegisterState, RegisterAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: RegisterState(), reducer: RegisterReducer, environment: RegisterEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: RegisterAction.init))
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
    let titleRegister = UILabel()
    titleRegister.text = "Register"
    titleRegister.font = UIFont.boldSystemFont(ofSize: 30)
    titleRegister.textAlignment = .left
    titleRegister.translatesAutoresizingMaskIntoConstraints = false
      // emailTextField
    let emailTextField = TextField()
    emailTextField.placeholder = "email"
    emailTextField.backgroundColor = UIColor(Color.gray.opacity(0.1))
      // passwordTextField
    let passwordTextField = TextField()
    passwordTextField.isSecureTextEntry = true
    passwordTextField.placeholder = "password"
    passwordTextField.backgroundColor = UIColor(Color.gray.opacity(0.1))
      // buttonRegister
    let buttonRegister = UIButton(type: .system)
    buttonRegister.setTitle("Register", for: .normal)
    buttonRegister.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    buttonRegister.setTitleColor(UIColor(Color.blue), for: .normal)
    buttonRegister.translatesAutoresizingMaskIntoConstraints = false
    buttonRegister.backgroundColor = UIColor(Color.blue)
    buttonRegister.setTitleColor(UIColor(Color.white), for: .normal)
      /// containerView
    let rootStackView = UIStackView(arrangedSubviews: [
      titleRegister,
      emailTextField,
      passwordTextField,
      buttonRegister
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
      titleRegister.heightAnchor.constraint(equalToConstant: 50),
      titleRegister.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      titleRegister.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // passwordTextField
      emailTextField.heightAnchor.constraint(equalToConstant: 50),
      emailTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      emailTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // passwordTextField
      passwordTextField.heightAnchor.constraint(equalToConstant: 50),
      passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      passwordTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
      // buttonLogin
      buttonRegister.heightAnchor.constraint(equalToConstant: 52),
      buttonRegister.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      buttonRegister.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
    ])
    
      //bind view to viewstore
    buttonRegister.tapPublisher
      .map{ViewAction.register}
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

struct RegisterViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = RegisterViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
  }
}

fileprivate struct ViewState: Equatable {
  init(state: RegisterState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case register
  init(action: RegisterAction) {
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

fileprivate extension RegisterAction {
  init(action: ViewAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    case .register:
      self = .registerSuccess
    default:
      self = .none
    }
  }
}
