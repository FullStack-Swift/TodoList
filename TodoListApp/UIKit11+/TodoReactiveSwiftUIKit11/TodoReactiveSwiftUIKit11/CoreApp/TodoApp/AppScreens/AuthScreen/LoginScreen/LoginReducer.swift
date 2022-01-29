import ComposableArchitecture
import Foundation

let LoginReducer = Reducer<LoginState, LoginAction, LoginEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
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
)
  .debug()
