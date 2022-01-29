import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var title: String = ""
  var todos: IdentifiedArrayOf<TodoModel> = []
  var isLoading: Bool = false
}
