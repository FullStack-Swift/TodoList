import ComposableArchitecture
import Foundation
import RealmSwift

struct MainState: Equatable {
  var optionalCounterState: CounterState?
  var title: String = ""
  var todos: IdentifiedArrayOf<TodoModel> = []
  var isLoading: Bool = false
  var networkStatus: NetworkStatus = .none
  var results: Results<RealmTodo>?
  var socketStringsOffline = [String?]()
}
