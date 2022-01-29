import ComposableArchitecture
import Foundation

let LoginReducer = Reducer<LoginState, LoginAction, LoginEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .loginSuccess:
      break
    default:
      break
    }
    return .none
  }
)
  .debug()
