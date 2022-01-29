import ComposableArchitecture
import Foundation

let AuthReducer = Reducer<AuthState, AuthAction, AuthEnvironment>.combine(
  RegisterReducer.pullback(state: \.registerState, action: /AuthAction.registerAction, environment: { _ in
      .init()
  }),
  
  LoginReducer.pullback(state: \.loginState, action: /AuthAction.loginAction, environment: { _ in
      .init()
  }),

  Reducer { state, action, environment in
    switch action {
    case .registerAction(let registerAction):
      switch registerAction {
      case .registerSuccess:
        return Effect(value: AuthAction.changeRootScreen(.main))
      default:
        break
      }
    case .loginAction(let loginAction):
      switch loginAction {
      case .loginSuccess:
        return Effect(value: AuthAction.changeRootScreen(.main))
      default:
        break
      }
    case .viewOnAppear:
      break
    case .viewOnDisappear:
      break
    case .changeRootScreen(let screen):
      break
    case .changeAuthScreen(let screen):
      state.authScreen = screen
    default:
      break
    }
    return .none
  }
)
  .debug()
