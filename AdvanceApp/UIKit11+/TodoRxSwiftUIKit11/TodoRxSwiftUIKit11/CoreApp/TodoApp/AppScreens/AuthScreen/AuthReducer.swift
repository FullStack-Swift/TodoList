import ComposableArchitecture
import Foundation

let AuthReducer = Reducer<AuthState, AuthAction, AuthEnvironment>.combine(
  LoginReducer
    .optional()
    .pullback(state: \.loginState, action: /AuthAction.loginAction, environment: { _ in
      .init()
  }),
  RegisterReducer
    .optional()
    .pullback(state: \.registerState, action: /AuthAction.registerAction, environment: { _ in
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
    case .viewDidLoad:
      break
    case .viewWillAppear:
      break
    case .viewWillDisappear:
      break
    case .setNavigation(isActive: let isActive, screen: let screen):
      if isActive {
        switch screen {
        case .register:
          state.registerState = RegisterState()
        case .login:
          state.loginState = LoginState()
        case .root:
          state.registerState = nil
          state.loginState = nil
        }
      } else {
        state.registerState = nil
        state.loginState = nil
      }
    default:
      break
    }
    return .none
  }
)
  .debug()
