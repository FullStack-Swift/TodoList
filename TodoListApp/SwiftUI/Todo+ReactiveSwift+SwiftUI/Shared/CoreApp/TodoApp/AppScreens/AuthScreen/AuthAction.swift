import ComposableArchitecture
import Foundation

enum AuthAction: Equatable {
  case registerAction(RegisterAction)
  case loginAction(LoginAction)
  case viewOnAppear
  case viewOnDisappear
  case none
  case changeRootScreen(RootScreen)
  case changeAuthScreen(AuthScreen)
}
