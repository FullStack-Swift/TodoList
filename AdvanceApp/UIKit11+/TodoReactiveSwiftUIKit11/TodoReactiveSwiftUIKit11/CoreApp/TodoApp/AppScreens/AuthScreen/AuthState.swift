import ComposableArchitecture
import Foundation

struct AuthState: Equatable {
  var loginState: LoginState?
  var registerState: RegisterState?
}

enum AuthScreen: Equatable {
  case login
  case register
  case root
}
