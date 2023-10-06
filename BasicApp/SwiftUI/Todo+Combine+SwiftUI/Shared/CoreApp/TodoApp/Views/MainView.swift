import SwiftUI

struct Main: Reducer {
  
  // MARK: State
  struct State: Equatable {
    var counterState = Counter.State()
    @BindingState var text: String = ""
    var todos: IdentifiedArrayOf<TodoModel> = []
    var isLoading: Bool = false
  }
  
  // MARK: Action
  enum Action: BindableAction, Equatable {
    /// subview Action
    case counterAction(Counter.Action)
    /// view Action
    case viewOnAppear
    case viewOnDisappear
    case none
    case binding(_ action: BindingAction<Main.State>)
    case toggleTodo(TodoModel)
    case logout
    case changeRootScreen(Root.RootScreen)
    case viewCreateTodo
    /// network Action
    case getTodo
    case responseTodo(Data)
    case createOrUpdateTodo(TodoModel)
    case responseCreateOrUpdateTodo(Data)
    case updateTodo(TodoModel)
    case responseUpdateTodo(Data)
    case deleteTodo(TodoModel)
    case responseDeleteTodo(Data)
  }
  
  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.urlString) var urlString
  
  // MARK: Reducer
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
          // MARK: - SubView Action
        case .counterAction(let counterAction):
          print(counterAction)
          // MARK: - View Action
        case .viewOnAppear:
          return .send(.getTodo)
        case .viewOnDisappear:
          state = Main.State()
        case .binding(_):
          break
        case .toggleTodo(let todo):
          //        state.todos[id: todo.id]?.isCompleted.toggle()
          if var todo = state.todos.filter({$0.id == todo.id}).first {
            todo.isCompleted.toggle()
            return .send(.updateTodo(todo))
          }
        case .logout:
          return .send(.changeRootScreen(.auth))
        case .viewCreateTodo:
          if state.text.isEmpty {
            return .none
          }
          let text = state.text
          state.text = ""
          let id = uuid()
          let todo = TodoModel(id: id, text: text, isCompleted: false)
          return .send(.createOrUpdateTodo(todo))
          // MARK: - Networking
          /// GET TODO
        case .getTodo:
          if state.isLoading {
            return .none
          }
          state.isLoading = true
          state.todos.removeAll()
          let request = MRequest {
            RUrl(urlString)
            RMethod(.get)
          }
          if isUsingPublisher {
            return .publisher {
              request
                .compactMap{$0.data}
                .map(Main.Action.responseTodo)
                .eraseToAnyPublisher()
            }
          } else {
            return .run { [request] send in
              let data = try await request.data
              await send(.responseTodo(data))
            }
          }
        case .responseTodo(let data):
          log.info(Json(data))
          state.isLoading = false
          if let items = data.toModel([TodoModel].self) {
            for item in items {
              state.todos.updateOrAppend(item)
            }
          }
          /// CREATE OR UPDATE TODO
        case .createOrUpdateTodo(let todo):
          log.info(todo.toJson())
          let request = MRequest {
            RUrl(urlString)
            RMethod(.post)
            Rbody(todo.toData())
            REncoding(JSONEncoding.default)

          }
          if isUsingPublisher {
            return .publisher {
              request
                .printCURLRequest()
                .compactMap{$0.data}
                .map(Main.Action.responseCreateOrUpdateTodo)
                .eraseToAnyPublisher()
            }
          } else {
            return .run { [request] send in
              let data = try await request.data
              await send(.responseCreateOrUpdateTodo(data))
            }
          }
        case .responseCreateOrUpdateTodo(let data):
          log.info(Json(data))
          if let item = data.toModel(TodoModel.self) {
            state.todos.updateOrAppend(item)
          }
          /// UPDATE TODO
        case .updateTodo(let todo):
          let request = MRequest {
            RUrl(urlString)
              .withPath(todo.id.toString())
            Rbody(todo.toData())
            RMethod(.post)
            REncoding(JSONEncoding.default)
          }
          if isUsingPublisher {
            return .publisher {
              request
                .printCURLRequest()
                .compactMap{$0.data}
                .map(Main.Action.responseUpdateTodo)
                .eraseToAnyPublisher()
            }
          } else {
            return .run { [request] send in
              let data = try await request.data
              await send(.responseUpdateTodo(data))
            }
          }
        case .responseUpdateTodo(let data):
          log.info(data.toJson())
          if let item = data.toModel(TodoModel.self) {
            state.todos.updateOrAppend(item)
          }
          /// DELETE TODO
        case .deleteTodo(let todo):
          let request = MRequest {
            RUrl(urlString)
              .withPath(todo.id.toString())
            RMethod(.delete)
          }
          if isUsingPublisher {
            return .publisher {
              request
                .compactMap{$0.data}
                .map(Main.Action.responseDeleteTodo)
                .eraseToAnyPublisher()
            }
          } else {
            return .run { [request] send in
              let data = try await request.data
              await send(.responseDeleteTodo(data))
            }
          }
        case .responseDeleteTodo(let json):
          if let item = json.toModel(TodoModel.self) {
            state.todos.remove(item)
          }
        default:
          break
      }
      return .none
    }
    ._printChanges()
  }
}

struct MainView: View {
  
  private let store: StoreOf<Main>
  
  @ObservedObject
  private var viewStore: ViewStoreOf<Main>
  
  init(store: StoreOf<Main>? = nil) {
    let unwrapStore = store ?? Store(initialState: Main.State()) {
      Main()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
  }
  
  var body: some View {
    ZStack {
      NavigationView {
        content
          .navigationTitle("Todos")
          .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      }
      .navigationViewStyle(.stack)
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

extension MainView {
  /// create content view in screen
  private var content: some View {
    List {
      topview
      inputview
      ForEach(viewStore.todos) { todo in
        HStack {
          HStack {
            Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
              .frame(width: 40, height: 40, alignment: .center)
            Text(todo.text)
              .underline(todo.isCompleted, color: Color.black)
            Spacer()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.toggleTodo(todo))
          }
          Button {
            viewStore.send(.deleteTodo(todo))
          } label: {
            Text("Delete")
              .foregroundColor(Color.gray)
          }
        }
      }
    }
    .padding(.all, 0)
  }
  
  private var topview: some View {
    Section {
      ZStack(alignment: .center) {
        if viewStore.isLoading {
          ProgressView()
        } else {
          Text("Reload")
            .bold()
            .onTapGesture {
              viewStore.send(.getTodo)
            }
        }
      }
      .frame(height: 60)
      .frame(maxWidth: .infinity)
    }
  }
  
  private var inputview: some View {
    HStack {
      TextField("text", text: viewStore.$text)
      Button(action: {
        viewStore.send(.viewCreateTodo)
      }, label: {
        Text("Create")
          .bold()
          .foregroundColor(viewStore.text.isEmpty ? Color.gray : Color.green)
      })
      .disabled(viewStore.text.isEmpty)
    }
  }
  
  private var leadingBarItems: some View {
    CounterView(
      store: store
        .scope(
          state: \.counterState,
          action: Main.Action.counterAction
        )
    )
  }
  
  private var trailingBarItems: some View {
    Button {
      viewStore.send(.logout)
    } label: {
      Text("Logout")
        .foregroundColor(Color.blue)
    }
  }
}

#Preview {
  MainView()
}
