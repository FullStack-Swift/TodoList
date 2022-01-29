import ComposableArchitecture
import Foundation

enum AuthAction: Equatable {
  case loginAction(LoginAction)
  case registerAction(RegisterAction)
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case changeRootScreen(RootScreen)
  case setNavigation(isActive: Bool, screen: AuthScreen)
}
