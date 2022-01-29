import ComposableArchitecture
import SwiftUI
import UIKit
import RxCocoa

final class AuthViewController: UIViewController {
  
  private let store: Store<AuthState, AuthAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private let disposeBag = DisposeBag()
  
  init(store: Store<AuthState, AuthAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: AuthState(), reducer: AuthReducer, environment: AuthEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: AuthAction.init))
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
    let buttonLogin = UIButton(type: .system)
    buttonLogin.setTitle("Login", for: .normal)
    buttonLogin.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonLogin)
    NSLayoutConstraint.activate([
      buttonLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      buttonLogin.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    buttonLogin.rx.tap
      .map{_ in ViewAction.login}
      .bind(to: viewStore.action)
      .disposed(by: disposeBag)
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

struct AuthViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = AuthViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
  }
}

fileprivate struct ViewState: Equatable {
  
  init(state: AuthState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case login
  
  init(action: AuthAction) {
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

fileprivate extension AuthState {
  
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
      
    }
  }
  
}

fileprivate extension AuthAction {
  
  init(action: ViewAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    case .login:
      self = .login
    default:
      self = .none
    }
  }
}
