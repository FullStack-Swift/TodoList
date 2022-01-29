import ComposableArchitecture
import Foundation

enum RegisterAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case registerSuccess
}
