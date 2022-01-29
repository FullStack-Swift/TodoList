import ComposableArchitecture
import Foundation

enum MainAction: Equatable {
  
  // view action
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case logout
  case changeRootScreen(RootScreen)
  case changeText(String)
  
  // network action
  case getTodo
  case toggleTodo(Todo)
  case responseTodo(Data)
  case createTodo
  case responseCreateTodo(Data)
  case updateTodo(Todo)
  case responseUpdateTodo(Data)
  case deleteTodo(Todo)
  case reponseDeleteTodo(Data)

}
