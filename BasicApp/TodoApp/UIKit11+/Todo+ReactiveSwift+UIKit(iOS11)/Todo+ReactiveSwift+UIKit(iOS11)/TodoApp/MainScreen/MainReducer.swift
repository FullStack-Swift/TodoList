import ComposableArchitecture
import Foundation
import ConvertSwift
import Alamofire

let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  
  Reducer { state, action, environment in
    let urlString = "http://127.0.0.1:8080/todos"
    switch action {
      
      /// update state
    case .changeTextFieldTitle(let value):
      state.title = value
    case .toggleTodo(let todo):
      if var todo = state.todos.filter({$0 == todo}).first {
        todo.isCompleted.toggle()
        return Effect(value: MainAction.updateTodo(todo))
      }
      
      /// networking
    case .getTodo:
      state.isLoading = true
      state.todos.removeAll()
      return AF.request(urlString, method: .get).reactive
        .response(queue: .main)
        .delay(2, on: QueueScheduler.main)
        .compactMap{$0.data}
        .map(MainAction.responseTodo)
    case .responseTodo(let json):
      state.isLoading = false
      if let todos = json.toModel([Todo].self) {
        for todo in todos {
          state.todos.append(todo)
        }
      }
    case .createTodo:
      if state.title.isEmpty {
        return .none
      }
      var title = state.title
      state.title = ""
      let todo = Todo(id: nil, title: title, isCompleted: false)
      return AF.request(urlString, method: .post, parameters: todo)
        .reactive.response(queue: .main)
        .compactMap{$0.data}
        .map(MainAction.responseCreateTodo)
    case .responseCreateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.append(todo)
      }
    case .updateTodo(let todo):
      return AF.request(urlString + "/\(todo.id!)", method: .post, parameters: todo, encoder: JSONParameterEncoder.default)
        .reactive.response(queue: .main)
        .compactMap{$0.data}
        .map(MainAction.responseUpdateTodo)
    case .responseUpdateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        if let index = state.todos.firstIndex(where: { item in
          item.id == todo.id
        }) {
          state.todos[index] = todo
        }
      }
    case .deleteTodo(let todo):
      return AF.request(urlString + "/\(todo.id!)", method: .delete)
        .reactive.response(queue: .main)
        .compactMap{$0.data}
        .map(MainAction.reponseDeleteTodo)
    case .reponseDeleteTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.removeAll {
          $0.id == todo.id
        }
      }
    case .viewDidLoad:
      return Effect(value: MainAction.getTodo)
    case .viewWillDisappear:
      state = MainState()
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
    default:
      break
    }
    return .none
  }
)
  .debug()
