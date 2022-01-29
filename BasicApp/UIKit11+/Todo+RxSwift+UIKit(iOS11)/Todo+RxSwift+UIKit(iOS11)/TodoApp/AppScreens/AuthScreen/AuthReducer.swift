import ComposableArchitecture
import Foundation

let AuthReducer = Reducer<AuthState, AuthAction, AuthEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .viewDidLoad:
      break
    case .viewWillAppear:
      break
    case .viewWillDisappear:
      break
    case .login:
      return Effect(value: AuthAction.changeRootScreen(.main))
    default:
      break
    }
    return .none
  }
)
  .debug()
