import ComposableArchitecture
import Foundation
import AnyRequest
import ConvertSwift

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
      let request = Request {
        RMethod(.get)
        RUrl(urlString: urlString)
      }
      
      return request
        .delay(for: .seconds(1), scheduler: UIScheduler.shared) // fake loading
        .compactMap {$0.data}
        .map(MainAction.responseTodo).eraseToEffect()
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
      let request = Request {
        RUrl(urlString: urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseCreateTodo).eraseToEffect()
    case .responseCreateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.append(todo)
      }
    case .updateTodo(let todo):
      let request = Request {
        REncoding(.json)
        RUrl(urlString: urlString).withPath(todo.id)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseUpdateTodo).eraseToEffect()
    case .responseUpdateTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.updateOrAppend(todo)
      }
    case .deleteTodo(let todo):
      let request = Request {
        RUrl(urlString: urlString).withPath(todo.id)
        RMethod(.delete)
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.reponseDeleteTodo).eraseToEffect()
    case .reponseDeleteTodo(let data):
      if let todo = data.toModel(Todo.self) {
        state.todos.remove(todo)
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
