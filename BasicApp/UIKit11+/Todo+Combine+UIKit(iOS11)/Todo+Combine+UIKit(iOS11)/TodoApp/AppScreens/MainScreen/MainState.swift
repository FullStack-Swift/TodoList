import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var title: String = ""
  var todos: [Todo] = []
  var isLoading: Bool = false
}
