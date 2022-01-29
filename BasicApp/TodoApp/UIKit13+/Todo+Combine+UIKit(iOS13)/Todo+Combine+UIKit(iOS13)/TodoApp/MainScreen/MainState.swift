import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  @BindableState var title: String = ""
  var todos: IdentifiedArrayOf<Todo> = []
  var isLoading: Bool = false
}
