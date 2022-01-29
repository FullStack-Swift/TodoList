import ComposableArchitecture
import Foundation

struct AuthState: Equatable {
  var registerState = RegisterState()
  var loginState = LoginState()
  var authScreen: AuthScreen = .login
}

enum AuthScreen: Equatable {
  case login
  case register
}
