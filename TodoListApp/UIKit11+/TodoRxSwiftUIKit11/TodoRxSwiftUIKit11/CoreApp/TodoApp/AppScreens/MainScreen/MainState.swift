import ComposableArchitecture
import Foundation

struct MainState: Equatable {
  var optionalCounterState: CounterState?
  var title: String = ""
  var todos: [TodoModel] = []
  var isLoading: Bool = false
  var networkStatus: NetworkStatus = .none
  var socketStringsOffline = [String?]()
}
