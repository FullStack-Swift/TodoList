import ComposableArchitecture
import Foundation

enum MainAction: Equatable {
    // MARK: -  View Action
    /// lifecycle action
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case viewDeinit
    ///  navigation view
  case logout
  case changeRootScreen(RootScreen)
  
    /// binding
  case changeText(String)
    /// event network
  case viewCreateTodo
  case viewReloadTodo
  case viewToggleTodo(TodoModel)
  case viewDeleteTodo(TodoModel)
  // MARK: - Store Action
  case resetText
    /// network Action
  case getTodo
  case responseGetTodo(Data)
  case createOrUpdateTodo(TodoModel)
  case responseCreateOrUpdateTodo(Data)
  case updateTodo(TodoModel)
  case responseUpdateTodo(Data)
  case deleteTodo(TodoModel)
  case reponseDeleteTodo(Data)
  // MARK: - none
  case none
}
