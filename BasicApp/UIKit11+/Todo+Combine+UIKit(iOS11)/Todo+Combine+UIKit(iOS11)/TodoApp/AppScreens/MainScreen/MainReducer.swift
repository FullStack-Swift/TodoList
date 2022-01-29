import ComposableArchitecture
import Foundation
import Alamofire
import ConvertSwift
import OpenCombine

let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  
  Reducer { state, action, environment in
    let urlString = "https://todolistappproj.herokuapp.com/todos"
    switch action {
        /// view action
    case .viewDidLoad:
      return Effect(value: MainAction.getTodo)
    case .viewWillDisappear:
      state = MainState()
    case .changeText(let value):
      state.title = value
    case .toggleTodo(let todo):
      if var todo = state.todos.filter({$0 == todo}).first {
        todo.isCompleted.toggle()
        return Effect(value: MainAction.updateTodo(todo))
      }
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
      /// networking
    case .getTodo:
      if state.isLoading {
        return .none
      }
      state.isLoading = true
      state.todos.removeAll()
      return AF.request(urlString, method: .get)
        .publisher()
        .compactMap{$0}
        .delay(for: .seconds(2), scheduler: ImmediateScheduler.shared)
        .map(MainAction.responseTodo)
        .eraseToEffect()
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
        .publisher()
        .compactMap{$0}
        .map(MainAction.responseCreateTodo)
        .eraseToEffect()
    case .responseCreateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.append(todo)
      }
    case .updateTodo(let todo):
      return AF.request(urlString + "/\(todo.id!)", method: .post, parameters: todo, encoder: JSONParameterEncoder.default)
        .publisher()
        .compactMap{$0}
        .map(MainAction.responseUpdateTodo)
        .eraseToEffect()
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
        .publisher()
        .compactMap{$0}
        .map(MainAction.reponseDeleteTodo)
        .eraseToEffect()
    case .reponseDeleteTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.removeAll {
          $0.id == todo.id
        }
      }
    default:
      break
    }
    return .none
  }
)
  .debug()