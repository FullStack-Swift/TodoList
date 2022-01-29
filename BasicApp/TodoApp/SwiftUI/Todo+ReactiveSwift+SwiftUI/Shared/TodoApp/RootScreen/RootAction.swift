import ComposableArchitecture
import Foundation

enum RootAction: Equatable {
  case authAction(AuthAction)
  case mainAction(MainAction)
  case viewOnAppear
  case viewOnDisappear
  case none
}
