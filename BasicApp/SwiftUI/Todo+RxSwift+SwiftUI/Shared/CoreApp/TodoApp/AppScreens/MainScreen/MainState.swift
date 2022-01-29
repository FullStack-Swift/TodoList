import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var counterState = CounterState()
  @BindableState var title: String = ""
  var todos: IdentifiedArrayOf<TodoModel> = []
  var isLoading: Bool = false
}
