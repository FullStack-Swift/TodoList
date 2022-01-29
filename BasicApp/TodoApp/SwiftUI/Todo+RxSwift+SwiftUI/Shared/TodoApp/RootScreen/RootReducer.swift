import ComposableArchitecture
import Foundation

let RootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  MainReducer.pullback(state: \.mainState, action: /RootAction.mainAction, environment: { _ in
      .init()
  }),
  AuthReducer.pullback(state: \.authState, action: /RootAction.authAction, environment: { _ in
      .init()
  }),
  Reducer { state, action, environment in
    switch action {
    case .authAction(.changeRootScreen(let screen)):
      state.rootScreen = screen
    case .mainAction(.changeRootScreen(let screen)):
      state.rootScreen = screen
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    default:
      break
    }
    return .none
  }
)
  .debug()
