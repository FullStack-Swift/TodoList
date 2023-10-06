import SwiftUI
import UIKit

struct RootReducer: Reducer {
  struct State: Equatable {
    var authState = AuthReducer.State()
    var mainState = MainReducer.State()
    var rootScreen: RootScreen = .main
  }
  
  enum Action {
    case authAction(AuthReducer.Action)
    case mainAction(MainReducer.Action)
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
    case none
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .authAction(.changeRootScreen(let screen)):
          state.rootScreen = screen
        case .mainAction(.changeRootScreen(let screen)):
          state = .init()
          state.rootScreen = screen
        case .viewDidLoad:
          break
        case .viewWillAppear:
          break
        case .viewWillDisappear:
          break
        default:
          break
      }
      return .none
    }
    ._printChanges()
    Scope(state: \.authState, action: /Action.authAction) {
      AuthReducer()
    }
    Scope(state: \.mainState, action: /Action.mainAction) {
      MainReducer()
    }
  }

  
  enum RootScreen: Equatable {
    case main
    case auth
  }

}

final class RootViewController: BaseViewController {

  private let store: StoreOf<RootReducer>
  
  private var viewStore: ViewStoreOf<RootReducer>
  
  init(store: StoreOf<RootReducer>? = nil) {
    let unwrapStore = store ?? Store(initialState: RootReducer.State()) {
      RootReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
    super.init(nibName: nil, bundle: nil)
  }

  private var viewController = UIViewController() {
    willSet {
      viewController.willMove(toParent: nil)
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
      addChild(newValue)
      newValue.view.frame = self.view.frame
      view.addSubview(newValue.view)
      newValue.didMove(toParent: self)
    }
  }

  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
      //bind view to viewstore
    disposables += viewStore.publisher.rootScreen.producer.startWithValues { [weak self] screen in
      guard let self = self else {return}
      switch screen {
      case .main:
          let vc = MainViewController(store: self.store.scope(state: \.mainState, action: RootReducer.Action.mainAction))
        let nav = UINavigationController(rootViewController: vc)
        self.viewController = nav
      case .auth:
          let vc = AuthViewController(store: self.store.scope(state: \.authState, action: RootReducer.Action.authAction))
        self.viewController = vc
      }
    }
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
  RootViewController().toSwiftUI()
}
