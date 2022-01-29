import ComposableArchitecture
import ReactiveSwiftRequest
import ConvertSwift

let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
        /// view action
    case .viewDidLoad:
      return Effect<MainAction, Never>(value: MainAction.viewReloadTodo)
    case .viewWillAppear:
      break
    case .viewWillDisappear:
      break
    case .viewDeinit:
      break
        ///  navigation view
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
    case .changeText(let text):
      state.title = text
    case .resetText:
      state.title = ""
        /// event network
    case .viewCreateTodo:
      if state.title.isEmpty {
        return .none
      }
      var title = state.title
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      let resetTitleEffect = Effect<MainAction, Never>(value: MainAction.resetText)
        .delay(0.3, on: QueueScheduler.main)
        .eraseToEffect()
      return Effect.merge(
        resetTitleEffect,
        Effect(value: MainAction.createOrUpdateTodo(todo))
      )
    case .viewReloadTodo:
      if state.isLoading {
        return .none
      }
      state.todos.removeAll()
      state.isLoading = true
      return Effect(value: MainAction.getTodo)
        .delay(0.3, on: QueueScheduler.main)
        .eraseToEffect()
    case .viewToggleTodo(let todo):
      var todo = todo
      todo.isCompleted.toggle()
      return Effect(value:  MainAction.updateTodo(todo))
    case .viewDeleteTodo(let todo):
      return Effect(value: MainAction.deleteTodo(todo))
        /// network action
    case .getTodo:
      let request = MRequest {
        RMethod(.get)
        RUrl(urlString: environment.urlString)
      }
      return request
        .producer
        .compactMap {$0.data}
        .map(MainAction.responseGetTodo)
        .eraseToEffect()
    case .responseGetTodo(let data):
      state.isLoading = false
      guard let todos = data.toModel([TodoModel].self) else {
        return .none
      }
      for todo in todos {
        state.todos.updateOrAppend(todo)
      }
    case .createOrUpdateTodo(let todo):
      let request = MRequest {
        RUrl(urlString: environment.urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .producer
        .compactMap {$0.data}
        .map(MainAction.responseCreateOrUpdateTodo)
        .eraseToEffect()
    case .responseCreateOrUpdateTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
      state.todos.append(todo)
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
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
      state.todos.updateOrAppend(todo)
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
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
      state.todos.remove(todo)
      break
    default:
      break
    }
    return .none
  }
)
  .debug()
