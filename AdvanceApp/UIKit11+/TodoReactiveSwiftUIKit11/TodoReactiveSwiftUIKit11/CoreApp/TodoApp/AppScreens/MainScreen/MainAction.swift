import ComposableArchitecture
import Foundation
import ReactiveSwiftWebSocket

enum MainAction: Equatable {
    /// subview Action
  case counterAction(CounterAction)
    /// view Action
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case viewDeinit
  case none
  case toggleTodo(TodoModel)
  case logout
  case changeTextFieldTitle(String)
  case changeRootScreen(RootScreen)
  case subscribeNetworkStatus(NetworkStatus)
  case viewCreateTodo
  case setNavigation(isActive: Bool)
  case resetTitle
    /// network Action
  case getTodo
  case responseTodo(Data)
  case createOrUpdateTodo(TodoModel)
  case responseCreateOrUpdateTodo(Data)
  case updateTodo(TodoModel)
  case responseUpdateTodo(Data)
  case deleteTodo(TodoModel)
  case reponseDeleteTodo(Data)
    /// socket Action
  case startSocket
  case stopSocket
  case receiveSocket(WebSocketEvent)
  case sendSocket(String?)
}
