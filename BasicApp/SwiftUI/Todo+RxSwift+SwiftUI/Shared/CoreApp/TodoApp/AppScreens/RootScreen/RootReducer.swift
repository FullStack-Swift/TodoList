import ComposableArchitecture
import Foundation

let RootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  MainReducer
    .pullback(state: \.mainState, action: /RootAction.mainAction, environment: { _ in
      .init()
  }),
  AuthReducer
    .pullback(state: \.authState, action: /RootAction.authAction, environment: { _ in
      .init()
  }),
  Reducer { state, action, environment in
    switch action {
    case .authAction(.changeRootScreen(let screen)):
      return Effect(value: RootAction.changeRootScreen(screen))
    case .mainAction(.changeRootScreen(let screen)):
      return Effect(value: RootAction.changeRootScreen(screen))
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .changeRootScreen(let screen):
      state.rootScreen = screen
    default:
      break
    }
    return .none
  }
)
  .debug()
