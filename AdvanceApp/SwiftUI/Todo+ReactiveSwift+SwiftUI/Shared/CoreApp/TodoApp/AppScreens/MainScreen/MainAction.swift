import ComposableArchitecture
import Foundation
import ReactiveSwiftWebSocket
import RealmSwift

enum MainAction: BindableAction, Equatable {
    /// subview Action
  case counterAction(CounterAction)
    /// view Action
  case viewOnAppear
  case viewOnDisappear
  case none
  case binding(_ action: BindingAction<MainState>)
  case toggleTodo(TodoModel)
  case logout
  case changeRootScreen(RootScreen)
  case subscribeNetworkStatus(NetworkStatus)
  case viewCreateTodo
    /// network Action
  case getTodo
  case responseTodo(Data)
  case createOrUpdateTodo(TodoModel)
  case responseCreateOrUpdateTodo(Data)
  case updateTodo(TodoModel)
  case responseUpdateTodo(Data)
  case deleteTodo(TodoModel)
  case reponseDeleteTodo(Data)
    /// realm Action
  case subscriberRealm
  case unSubscriberRealm
  case responseSubscriberRealm(Results<RealmTodo>)
    /// socket Action
  case startSocket
  case stopSocket
  case receiveSocket(WebSocketEvent)
  case sendSocket(String?)
}
