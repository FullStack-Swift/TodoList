import ComposableArchitecture
import CombineRequest
import ConvertSwift
import Foundation

let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  CounterReducer
    .pullback(state: \.counterState, action: /MainAction.counterAction, environment: { _ in
      .init()
  }),
  Reducer { state, action, environment in
    switch action {
      /// view action
    case .viewOnAppear:
      return Effect(value: MainAction.getTodo)
    case .viewOnDisappear:
      state = MainState()
    case .binding(let bindingAction):
      break
    case .toggleTodo(let todo):
      if var todo = state.todos.filter({$0 == todo}).first {
        todo.isCompleted.toggle()
        return Effect(value: MainAction.updateTodo(todo))
      }
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
    case .viewCreateTodo:
      if state.title.isEmpty {
        return .none
      }
      var title = state.title
      state.title = ""
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      return Effect(value: MainAction.createOrUpdateTodo(todo))
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
        .compactMap {$0.data}
        .map(MainAction.responseTodo)
        .eraseToEffect()
    case .responseTodo(let json):
      state.isLoading = false
      if let todos = json.toModel([TodoModel].self) {
        for todo in todos {
          state.todos.updateOrAppend(todo)
        }
      }
    case .createOrUpdateTodo(let todo):
      let request = MRequest {
        RUrl(urlString: environment.urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseCreateOrUpdateTodo)
        .eraseToEffect()
    case .responseCreateOrUpdateTodo(let data):
      if let todo = data.toModel(TodoModel.self) {
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
        .compactMap {$0.data}
        .map(MainAction.responseUpdateTodo)
        .eraseToEffect()
    case .responseUpdateTodo(let data):
      if let todo = data.toModel(TodoModel.self) {
        state.todos.updateOrAppend(todo)
      }
    case .deleteTodo(let todo):
      let request = MRequest {
        RUrl(urlString: environment.urlString)
          .withPath(todo.id.toString())
        RMethod(.delete)
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.reponseDeleteTodo)
        .eraseToEffect()
    case .reponseDeleteTodo(let data):
      if let todo = data.toModel(TodoModel.self) {
        state.todos.remove(todo)
      }
    default:
      break
    }
    return .none
  }
)
  .binding()
  .debug()
