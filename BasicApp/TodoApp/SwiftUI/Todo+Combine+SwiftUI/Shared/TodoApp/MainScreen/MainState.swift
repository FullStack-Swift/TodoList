import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var counterState = CounterState()
  @BindableState var title: String = ""
  var todos: IdentifiedArrayOf<Todo> = []
  var isLoading: Bool = false
}
