import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var title: String = ""
  var todos: [TodoModel] = []
  var isLoading: Bool = false
}
