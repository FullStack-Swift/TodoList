import SwiftUI
import UIKit

struct AuthReducer: Reducer {
  
  struct State: Equatable {
    
  }
  
  enum Action {
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
    case none
    case login
    case changeRootScreen(RootReducer.RootScreen)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewDidLoad:
          break
        case .viewWillAppear:
          break
        case .viewWillDisappear:
          break
        case .login:
          return .send(.changeRootScreen(.main))
        default:
          break
      }
      return .none
    }
  }
}

final class AuthViewController: BaseViewController {
  
  private let store: StoreOf<AuthReducer>
  
  private var viewStore: ViewStoreOf<AuthReducer>
  
  init(store: StoreOf<AuthReducer>? = nil) {
    let unwrapStore = store ?? Store(initialState: AuthReducer.State()) {
      AuthReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
      // buttonLogin
      let buttonLogin = UIButton(type: .system)
      buttonLogin.setTitle("Login", for: .normal)
      buttonLogin.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(buttonLogin)
      // contraint
      NSLayoutConstraint.activate([
        buttonLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        buttonLogin.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      ])
    
      //bind view to viewstore
    buttonLogin.rx.tap
      .map { AuthReducer.Action.login }
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

#Preview {
  AuthViewController().toSwiftUI()
}
