import ComposableArchitecture
import Foundation

enum MainAction: BindableAction, Equatable {
  case counterAction(CounterAction)
  case viewOnAppear
  case viewOnDisappear
  case none
  case binding(_ action: BindingAction<MainState>)
  case getTodo
  case toggleTodo(Todo)
  case responseTodo(Data)
  case createTodo
  case responseCreateTodo(Data)
  case updateTodo(Todo)
  case responseUpdateTodo(Data)
  case deleteTodo(Todo)
  case reponseDeleteTodo(Data)
  case logout
  case changeRootScreen(RootScreen)
}
