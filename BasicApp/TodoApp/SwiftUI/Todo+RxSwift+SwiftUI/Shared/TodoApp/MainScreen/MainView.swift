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
      List {
        HStack {
          Spacer()
          Text(viewStore.isLoading ? "Loading" : "Reload")
            .bold()
          Spacer()
        }
        .onTapGesture {
          viewStore.send(.getTodo)
        }
        HStack {
          TextField("title", text: viewStore.$title)
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
#if os(iOS)
        .listStyle(PlainListStyle())
#else
        .listStyle(PlainListStyle())
#endif
        
        .padding(.all, 0)
      }
      .padding(.all, 0)
#if os(macOS)
      .toolbar {
        ToolbarItem(placement: .status) {
          HStack {
            CounterView()
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
      .navigationTitle("Todos")
      .navigationViewStyle(.stack)
      .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      .embedNavigationView()
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
  
  private var leadingBarItems: some View {
    CounterView()
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
  var todos: IdentifiedArrayOf<Todo> = []
  var isLoading: Bool = false
  init(state: MainState) {
    self.title = state.title
    self.todos = state.todos
    self.isLoading = state.isLoading
  }
}

fileprivate enum ViewAction: BindableAction, Equatable {
  case binding(_ action: BindingAction<ViewState>)
  case getTodo
  case toggleTodo(Todo)
  case createTodo
  case updateTodo(Todo)
  case deleteTodo(Todo)
  case logout
  case viewOnAppear
  case viewOnDisappear
  case none
  
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
      self = .createTodo
    case .deleteTodo(let todo):
      self = .deleteTodo(todo)
    case .logout:
      self = .logout
    default:
      self = .none
    }
  }
}

extension View {
  func embedNavigationView() -> some View {
    NavigationView {
      self
    }
  }
}
