import ComposableArchitecture
import SwiftUI

struct MainView: View {
  
  private let store: Store<MainState, MainAction>
  
  @ObservedObject
  private var viewStore: ViewStore<ViewState, ViewAction>
  
  init(store: Store<MainState, MainAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: MainState(), reducer: MainReducer, environment: MainEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: MainAction.init))
  }
  
  var body: some View {
    ZStack {
#if os(macOS)
      content
        .toolbar {
          ToolbarItem(placement: .status) {
            HStack {
              CounterView(store: store.scope(state: \.counterState, action: MainAction.counterAction))
              Spacer()
              Button(action: {
                viewStore.send(.logout)
              }, label: {
                Text("Logout")
                  .foregroundColor(Color.blue)
              })
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(iOS)
      NavigationView {
        content
          .navigationTitle("Todos")
          .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      }
      .navigationViewStyle(.stack)
#endif
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
      Section {
        ZStack {
          HStack {
            Spacer()
            if viewStore.isLoading {
              ProgressView()
            } else {
              Text("Reload")
                .bold()
                .onTapGesture {
                  viewStore.send(.getTodo)
                }
            }
            Spacer()
          }
          .frame(height: 60)
          HStack {
            Spacer()
            if viewStore.networkStatus == .online {
              Spacer()
              Text("Online")
                .bold()
                .foregroundColor(.green)
            } else {
              Spacer()
              Text("Offline")
                .bold()
            }
          }
        }
      }
      HStack {
        TextField("title", text: viewStore.binding(\.$title))
        Button(action: {
          viewStore.send(.createTodo)
        }, label: {
          Text("Create")
            .bold()
            .foregroundColor(viewStore.title.isEmpty ? Color.gray : Color.green)
        })
          .disabled(viewStore.title.isEmpty)
      }
      
      ForEach(viewStore.todos) { todo in
        HStack {
          HStack {
            Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
              .frame(width: 40, height: 40, alignment: .center)
            Text(todo.title)
              .underline(todo.isCompleted, color: Color.black)
            Spacer()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.toggleTodo(todo))
          }
          Button(action: {
            viewStore.send(.deleteTodo(todo))
          }, label: {
            Text("Delete")
              .foregroundColor(Color.gray)
          })
        }
      }
      .padding(.all, 0)
    }
    .padding(.all, 0)
  }
  
  private var leadingBarItems: some View {
    CounterView(store: store.scope(state: \.counterState, action: MainAction.counterAction))
  }
  
  private var trailingBarItems: some View {
    Button(action: {
      viewStore.send(.logout)
    }, label: {
      Text("Logout")
        .foregroundColor(Color.blue)
    })
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

fileprivate struct ViewState: Equatable {
  @BindableState var title: String = ""
  var todos: IdentifiedArrayOf<TodoModel> = []
  var isLoading: Bool = false
  var networkStatus: NetworkStatus = .none
  init(state: MainState) {
    self.title = state.title
    self.isLoading = state.isLoading
    self.networkStatus = state.networkStatus
    if let results = state.results {
      for item in Array(results).asArrayTodo() {
        self.todos.append(item)
      }
    }
  }
}

fileprivate enum ViewAction: BindableAction, Equatable {
  case binding(_ action: BindingAction<ViewState>)
  case getTodo
  case toggleTodo(TodoModel)
  case createTodo
  case updateTodo(TodoModel)
  case deleteTodo(TodoModel)
  case logout
  case viewOnAppear
  case viewOnDisappear
  case none
    /// init ViewAction
    /// - Parameter action: MainAction
  init(action: MainAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    default:
      self = .none
    }
  }
}

fileprivate extension MainState {
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
      self.title = newValue.title
    }
  }
}

fileprivate extension MainAction {
  init(action: ViewAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    case .binding(let bindingAction):
      self = .binding(bindingAction.pullback(\.viewState))
    case .getTodo:
      self = .getTodo
    case .toggleTodo(let todo):
      self = .toggleTodo(todo)
    case .createTodo:
      self = .viewCreateTodo
    case .deleteTodo(let todo):
      self = .deleteTodo(todo)
    case .logout:
      self = .logout
    default:
      self = .none
    }
  }
}
