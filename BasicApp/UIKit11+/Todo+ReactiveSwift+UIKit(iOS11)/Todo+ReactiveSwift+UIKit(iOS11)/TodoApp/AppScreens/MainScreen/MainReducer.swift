import ComposableArchitecture
import Foundation
import ConvertSwift
import ReactiveSwiftRequest

let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  
  Reducer { state, action, environment in
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
      let request = MRequest {
        RMethod(.get)
        RUrl(urlString: environment.urlString)
      }
      return request
        .producer
        .compactMap {$0.data}
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
      let request = MRequest {
        RUrl(urlString: environment.urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .producer
        .compactMap {$0.data}
        .map(MainAction.responseCreateTodo)
        .eraseToEffect()
    case .responseCreateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.append(todo)
      }
    case .updateTodo(let todo):
      let request = MRequest {
        REncoding(.json)
        RUrl(urlString: environment.urlString)
          .withPath(todo.id.toString())
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .producer
        .compactMap {$0.data}
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
      let request = MRequest {
        RUrl(urlString: environment.urlString)
          .withPath(todo.id.toString())
        RMethod(.delete)
      }
      return request
        .producer
        .compactMap {$0.data}
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
