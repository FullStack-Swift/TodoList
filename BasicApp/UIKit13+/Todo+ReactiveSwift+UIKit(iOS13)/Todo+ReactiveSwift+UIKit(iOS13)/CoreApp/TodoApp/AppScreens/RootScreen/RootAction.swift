import ComposableArchitecture
import Foundation

enum RootAction: Equatable {
  case authAction(AuthAction)
  case mainAction(MainAction)
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
}
