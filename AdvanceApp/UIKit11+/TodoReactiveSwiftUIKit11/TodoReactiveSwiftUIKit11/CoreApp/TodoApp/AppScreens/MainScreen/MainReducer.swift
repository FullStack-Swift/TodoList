import ComposableArchitecture
import ReactiveSwiftRequest
import ReactiveSwiftWebSocket
import ConvertSwift
import Foundation

  // cannot using Enviroment because Enviroment reinit when reducer running, so we cannot keep reference
var socket: MSocket?
let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  CounterReducer
    .optional()
    .pullback(state: \.optionalCounterState, action: /MainAction.counterAction, environment: { _ in
    .init()
    }),
  Reducer { state, action, environment in
    struct CanncelRealm: Hashable {}
    struct CanncelSocket: Hashable {}
    struct CanncelRequest: Hashable {}
    switch action {
        /// view action
    case .viewDidLoad:
      return Effect<MainAction, Never>
        .merge (
          environment.status.publisherNetworkNetworkStatus()
            .map(MainAction.subscribeNetworkStatus)
            .eraseToEffect(),
          Effect<MainAction, Never>(value: MainAction.startSocket)
        )
    case .viewWillAppear:
      break
    case .viewWillDisappear:
      break
    case .viewDeinit:
      return Effect<MainAction, Never>
        .merge(
          Effect<MainAction, Never>(value: MainAction.stopSocket)
        )
    case .changeTextFieldTitle(let text):
      state.title = text
    case .setNavigation(isActive: let isActive):
      if isActive {
        state.optionalCounterState = CounterState()
      } else {
        state.optionalCounterState = nil
      }
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
    case .toggleTodo(let todo):
      var todo = todo
      todo.isCompleted.toggle()
      return Effect(value:  MainAction.updateTodo(todo))
    case .viewCreateTodo:
      if state.title.isEmpty {
        return .none
      }
      var title = state.title
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      let resetTitleEffect = Effect<MainAction, Never>(value: MainAction.resetTitle)
        .delay(0.3, on: QueueScheduler())
        .eraseToEffect()
      return Effect.merge(resetTitleEffect,
                          Effect(value: MainAction.createOrUpdateTodo(todo)))
    case .resetTitle:
      state.title = ""
    case .subscribeNetworkStatus(let status):
      state.networkStatus = status
      if status == .online {
        return Effect<MainAction, Never>.merge (
          /// sync data from server
          Effect<MainAction, Never>(value: MainAction.getTodo)
        )
      }
        /// network action
    case .getTodo:
        /// realtime data
      if state.networkStatus == .online {
        state.isLoading = true
        let request = MRequest {
          RMethod(.get)
          RUrl(urlString: environment.urlString)
        }
        return request.producer
          .compactMap {$0.data}
          .map(MainAction.responseTodo)
          .eraseToEffect()
          .cancellable(id: CanncelRequest(), cancelInFlight: true)
      } else {
        state.isLoading = false
      }
    case .responseTodo(let json):
      state.isLoading = false
      guard let todos = json.toModel([TodoModel].self) else {
        return .none
      }
        /// updating in state
      for todo in todos {
        state.todos.append(todo)
      }
    case .createOrUpdateTodo(let todo):
        /// realtime data
      if state.networkStatus == .online {
        let request = MRequest {
          RUrl(urlString: environment.urlString)
          REncoding(.json)
          RMethod(.post)
          Rbody(todo.toData())
        }
        return request.producer
          .compactMap {$0.data}
          .map(MainAction.responseCreateOrUpdateTodo)
          .eraseToEffect()
      }
    case .responseCreateOrUpdateTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// updating in state
      state.todos.append(todo)
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .created, value: todo).toData()?.toString()))
    case .updateTodo(let todo):
        /// realtime data
      if state.networkStatus == .online {
        let request = MRequest {
          REncoding(.json)
          RUrl(urlString: environment.urlString)
            .withPath(todo.id.toString())
          RMethod(.post)
          Rbody(todo.toData())
        }
        return request.producer
          .compactMap {$0.data}
          .map(MainAction.responseUpdateTodo)
          .eraseToEffect()
      }
    case .responseUpdateTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// updateOrAppend in state
      if let index = state.todos.firstIndex(where: { item in
        item.id == todo.id
      }) {
        state.todos[index] = todo
      } else {
        state.todos.append(todo)
      }
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .updated, value: todo).toData()?.toString()))
    case .deleteTodo(let todo):
        /// realtime data
      if state.networkStatus == .online {
        let request = MRequest {
          RUrl(urlString: environment.urlString)
            .withPath(todo.id.toString())
          RMethod(.delete)
        }
        return request.producer
          .compactMap {$0.data}
          .map(MainAction.reponseDeleteTodo)
          .eraseToEffect()
      }
    case .reponseDeleteTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// delete in state
      if let todo = data.toModel(TodoModel.self) {
        state.todos.removeAll {
          $0.id == todo.id
        }
      }
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .deleted, value: todo).toData()?.toString()))
        /// socket action
    case .startSocket:
      socket = MSocket {
        RUrl(urlString: "wss://todolistappproj.herokuapp.com/todo-list")
      }
      return socket!.producer
        .map(MainAction.receiveSocket)
        .eraseToEffect()
        .cancellable(id: CanncelSocket(), cancelInFlight: true)
    case .stopSocket:
      socket = nil
      return .cancel(id: CanncelSocket())
    case .sendSocket(let string):
      if state.networkStatus == .online {
        socket?.write(string: string)
      } else {
        state.socketStringsOffline.append(string)
      }
    case .receiveSocket(let event):
      switch event {
      case .text(let text):
        print(text)
        if let socketModel = text.toModel(SocketModel<TodoModel>.self) {
          let todo = socketModel.value
          switch socketModel.socketEvent {
          case .updated:
            break
          case .deleted:
            break
          case .created:
            break
          }
        }
      default:
        print(event)
      }
    default:
      break
    }
    return .none
  }
)
  .debug()
