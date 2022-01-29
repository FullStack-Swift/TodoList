import ComposableArchitecture
import ReactiveSwiftRequest
import ReactiveSwiftWebSocket
import ConvertSwift
import RealmSwift

// cannot using Enviroment because Enviroment reinit when reducer running, so we cannot keep reference
var socket: MSocket?
let MainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
  CounterReducer.pullback(state: \.counterState, action: /MainAction.counterAction, environment: { _ in
      .init()
  }),
  Reducer { state, action, environment in
    struct CanncelRealm: Hashable {}
    struct CanncelSocket: Hashable {}
    struct CanncelRequest: Hashable {}
    switch action {
        /// view action
    case .viewOnAppear:
      return Effect<MainAction, Never>
        .merge (
          environment.status.publisherNetworkNetworkStatus()
            .map(MainAction.subscribeNetworkStatus)
            .eraseToEffect(),
          Effect<MainAction, Never>(value: MainAction.subscriberRealm),
          Effect<MainAction, Never>(value: MainAction.startSocket)
        )
    case .viewOnDisappear:
      state = MainState()
      return Effect<MainAction, Never>
        .merge(
          Effect<MainAction, Never>(value: MainAction.unSubscriberRealm),
          Effect<MainAction, Never>(value: MainAction.stopSocket)
        )
    case .logout:
      return Effect(value: MainAction.changeRootScreen(.auth))
    case .binding(let bindingAction):
      break
    case .toggleTodo(let todo):
      var todo = todo
      todo.isCompleted.toggle()
      return Effect(value:  MainAction.updateTodo(todo))
    case .viewCreateTodo:
      if state.title.isEmpty {
        return .none
      }
      var title = state.title
      state.title = ""
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      return Effect(value: MainAction.createOrUpdateTodo(todo))
    case .subscribeNetworkStatus(let status):
      state.networkStatus = status
      if status == .online {
        let effectsDeleted: [Effect<MainAction, Never>] = Realm.instance.objects(RealmTodo.self).where {
          $0.status == .deletedOffline
        }
          .compactMap {
            let todo = $0.asTodoModel()
            return Effect<MainAction, Never>(value: MainAction.deleteTodo(todo))
          }
        let effectsUpdated: [Effect<MainAction, Never>] = Realm.instance.objects(RealmTodo.self).where {
          $0.status == .updatedOffline
        }
          .compactMap {
            let todo = $0.asTodoModel()
            return Effect<MainAction, Never>(value: MainAction.createOrUpdateTodo(todo))
          }
        let effectsCreated: [Effect<MainAction, Never>] = Realm.instance.objects(RealmTodo.self).where {
          $0.status == .createdOffline
        }
          .compactMap {
            let todo = $0.asTodoModel()
            return Effect<MainAction, Never>(value: MainAction.createOrUpdateTodo(todo))
          }
        return Effect<MainAction, Never>.merge (
          /// updated offline data in realm
          Effect<MainAction, Never>.merge(effectsCreated),
          Effect<MainAction, Never>.merge(effectsUpdated),
          Effect<MainAction, Never>.merge(effectsDeleted),
          /// sync data from server
          Effect<MainAction, Never>(value: MainAction.getTodo)
        )
      }
        /// realm action
    case .subscriberRealm:
      let todos = Realm.instance.objects(RealmTodo.self)
      return todos
        .collectionPublisher
        .assertNoFailure()
        .map(MainAction.responseSubscriberRealm)
        .eraseToEffect()
        .cancellable(id: CanncelRealm(), cancelInFlight: true)
    case .unSubscriberRealm:
      return .cancel(id: CanncelRealm())
    case .responseSubscriberRealm(let results):
      state.results = results.where({ realmTodo in
        realmTodo.status != .deletedOffline
      })
        /// network action
    case .getTodo:
        /// realtime data
      if state.networkStatus == .online {
        state.isLoading = true
          /// reset realm database when reload
        try! Realm.instance.write({
          Realm.instance.deleteAll()
        })
        let request = MRequest {
          RMethod(.get)
          RUrl(urlString: environment.urlString)
        }
        return request
          .producer
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
        /// updating in realm database
      let realmTodos: [RealmTodo] = todos.asArrayRealmTodo()
        .compactMap {
          $0.status = .syncOnline
          return $0
        }
      try! Realm.instance.write({
        Realm.instance.add(realmTodos, update: .all)
      })
    case .createOrUpdateTodo(let todo):
        /// updating in realm database
      let realmTodo = todo.asRealmTodo()
      realmTodo.status = .createdOffline
      try! Realm.instance.write({
        Realm.instance.add(realmTodo, update: .all)
      })
      
        /// realtime data
      if state.networkStatus == .online {
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
      }
    case .responseCreateOrUpdateTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// updating in state
      state.todos.append(todo)
        /// updating in realm database
      let realmTodo = todo.asRealmTodo()
      realmTodo.status = .syncOnline
      try! Realm.instance.write({
        Realm.instance.add(realmTodo, update: .all)
      })
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .created, value: todo).toData()?.toString()))
    case .updateTodo(let todo):
        /// updating in realm datbase
      var todos = Realm.instance.objects(RealmTodo.self)
        .where {
        $0._id == todo.id
      }
      try! Realm.instance.write({
        for var item in todos {
          item.title = todo.title
          item.isCompleted = todo.isCompleted
          item.status = .updatedOffline
        }
      })
        /// realtime data
      if state.networkStatus == .online {
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
      }
    case .responseUpdateTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// updating in state
      state.todos.updateOrAppend(todo)
        /// updating in realm datbase
      var todos = Realm.instance.objects(RealmTodo.self)
        .where {
        $0._id == todo.id
      }
      try! Realm.instance.write({
        for var item in todos {
          item.title = todo.title
          item.isCompleted = todo.isCompleted
          item.status = .syncOnline
        }
      })
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .updated, value: todo).toData()?.toString()))
    case .deleteTodo(let todo):
      let todos = Realm.instance.objects(RealmTodo.self)
        .where {
        $0._id == todo.id
      }
        /// updated in realm datbase
      try! Realm.instance.write({
        for item in todos {
          item.status = .deletedOffline
        }
      })
        /// realtime data
      if state.networkStatus == .online {
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
      }
    case .reponseDeleteTodo(let data):
      guard let todo = data.toModel(TodoModel.self) else {
        return .none
      }
        /// delete in state
      state.todos.remove(todo)
      let todos = Realm.instance.objects(RealmTodo.self).where {
        $0._id == todo.id
      }
        /// delete in realm datbase
      try! Realm.instance.write({
        Realm.instance.delete(todos)
      })
      return Effect(value: MainAction.sendSocket(SocketModel<TodoModel>(socketEvent: .deleted, value: todo).toData()?.toString()))
      /// socket action
    case .startSocket:
      socket = MSocket {
        RUrl(urlString: "wss://todolistappproj.herokuapp.com/todo-list")
      }      
      return socket!
        .producer
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
              /// updating in realm datbase
            var todos = Realm.instance.objects(RealmTodo.self)
              .where {
              $0._id == todo.id
            }
            try! Realm.instance.write({
              for var item in todos {
                item.title = todo.title
                item.isCompleted = todo.isCompleted
                item.status = .syncOnline
              }
            })
          case .deleted:
              /// delete in realm datbase
            let todos = Realm.instance.objects(RealmTodo.self).where {
              $0._id == todo.id
            }
            try! Realm.instance.write({
              Realm.instance.delete(todos)
            })
          case .created:
              /// updating in realm database
            let realmTodo = todo.asRealmTodo()
            realmTodo.status = .syncOnline
            try! Realm.instance.write({
              Realm.instance.add(realmTodo, update: .all)
            })
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
  .binding()
  .debug()
