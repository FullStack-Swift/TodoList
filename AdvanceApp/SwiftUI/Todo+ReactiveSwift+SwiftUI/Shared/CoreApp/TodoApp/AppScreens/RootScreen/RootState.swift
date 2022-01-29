import ComposableArchitecture
import Foundation

struct RootState: Equatable {
  var authState = AuthState()
  var mainState = MainState()
  var rootScreen: RootScreen = .main
}

enum RootScreen: Equatable {
  case main
  case auth
}
