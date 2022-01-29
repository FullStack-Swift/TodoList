import ComposableArchitecture
import Foundation

let RegisterReducer = Reducer<RegisterState, RegisterAction, RegisterEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .registerSuccess:
      break
    default:
      break
    }
    return .none
  }
)
  .debug()
