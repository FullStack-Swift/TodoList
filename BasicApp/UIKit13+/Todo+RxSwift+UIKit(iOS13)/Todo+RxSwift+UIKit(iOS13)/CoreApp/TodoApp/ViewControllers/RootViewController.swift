import SwiftUI
import UIKit

struct MainReducer: Reducer {
  struct State: Equatable {
    var text: String = ""
    var todos: IdentifiedArrayOf<TodoModel> = []
    var isLoading: Bool = false
  }
  
  enum Action: Equatable {
    // MARK: -  View Action
    /// lifecycle action
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
    case viewDeinit
    ///  navigation view
    case logout
    case changeRootScreen(RootReducer.RootScreen)
    
    /// binding
    case changeText(String)
    /// event network
    case viewCreateTodo
    case viewReloadTodo
    case viewToggleTodo(TodoModel)
    case viewDeleteTodo(TodoModel)
    // MARK: - Store Action
    case resetText
    /// network Action
    case getTodo
    case responseGetTodo(Data)
    case createOrUpdateTodo(TodoModel)
    case responseCreateOrUpdateTodo(Data)
    case updateTodo(TodoModel)
    case responseUpdateTodo(Data)
    case deleteTodo(TodoModel)
    case reponseDeleteTodo(Data)
    // MARK: - none
    case none
  }
  
  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.urlString) var urlString
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
          // MARK: - View Action
        case .viewDidLoad:
          return .send(.viewReloadTodo)
        case .viewWillAppear:
          break
        case .viewWillDisappear:
          break
        case .viewDeinit:
          break
          ///  navigation view
        case .logout:
          return .send(.changeRootScreen(.auth))
        case .changeText(let text):
          state.text = text
        case .resetText:
          state.text = ""
          /// event network
        case .viewCreateTodo:
          if state.text.isEmpty {
            return .none
          }
          let text = state.text
          let id = UUID()
          let todo = TodoModel(id: id, text: text, isCompleted: false)
          return Effect.merge(
            .publisher {
              .just(.resetText)
              .delay(.microseconds(300), scheduler: MainScheduler.instance)
            },
            .send(.createOrUpdateTodo(todo))
          )
        case .viewReloadTodo:
          if state.isLoading {
            return .none
          }
          state.todos.removeAll()
          state.isLoading = true
          return .publisher {
              .just(.getTodo)
              .delay(.microseconds(300), scheduler: MainScheduler.instance)
          }
        case .viewToggleTodo(let todo):
          var todo = todo
          todo.isCompleted.toggle()
          return .send(.updateTodo(todo))
        case .viewDeleteTodo(let todo):
          return .send(.deleteTodo(todo))
          /// network action
        case .getTodo:
          let request = MRequest {
            RMethod(.get)
            RUrl(urlString)
          }
          return .publisher {
            request
              .compactMap {$0.data}
              .map(Action.responseGetTodo)
          }
        case .responseGetTodo(let data):
          state.isLoading = false
          guard let todos = data.toModel([TodoModel].self) else {
            return .none
          }
          for todo in todos {
            state.todos.updateOrAppend(todo)
          }
        case .createOrUpdateTodo(let todo):
          return .publisher {
            let request = MRequest {
              RUrl(urlString)
              REncoding(JSONEncoding.default)
              RMethod(.post)
              Rbody(todo.toData())
            }
            return request
              .compactMap {$0.data}
              .map(Action.responseCreateOrUpdateTodo)
          }
        case .responseCreateOrUpdateTodo(let data):
          guard let todo = data.toModel(TodoModel.self) else {
            return .none
          }
          state.todos.append(todo)
        case .updateTodo(let todo):
          let request = MRequest {
            REncoding(JSONEncoding.default)
            RUrl(urlString)
              .withPath(todo.id.toString())
            RMethod(.post)
            Rbody(todo.toData())
          }
          return .publisher {
            request
              .compactMap {$0.data}
              .map(Action.responseUpdateTodo)
          }
        case .responseUpdateTodo(let data):
          guard let todo = data.toModel(TodoModel.self) else {
            return .none
          }
          state.todos.updateOrAppend(todo)
        case .deleteTodo(let todo):
          let request = MRequest {
            RUrl(urlString)
              .withPath(todo.id.toString())
            RMethod(.delete)
          }
          return .publisher {
            request
              .compactMap {$0.data}
              .map(Action.reponseDeleteTodo)
          }
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
  }
  
}

struct RootReducer: Reducer {
  
  struct State: Equatable {
    var authState = AuthReducer.State()
    var mainState = MainReducer.State()
    var rootScreen: RootScreen = .main
  }
  
  enum Action {
    case authAction(AuthReducer.Action)
    case mainAction(MainReducer.Action)
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .authAction(.changeRootScreen(let screen)):
          state.rootScreen = screen
        case .mainAction(.changeRootScreen(let screen)):
          state = .init()
          state.rootScreen = screen
        case .viewDidLoad:
          break
        case .viewWillAppear:
          break
        case .viewWillDisappear:
          break
        default:
          break
      }
      return .none
    }
    ._printChanges()
    Scope(state: \.authState, action: /Action.authAction) {
      AuthReducer()
    }
    Scope(state: \.mainState, action: /Action.mainAction) {
      MainReducer()
    }
  }
  
  enum RootScreen: Equatable {
    case main
    case auth
  }
  
}

final class RootViewController: BaseViewController {
  
  private let store: StoreOf<RootReducer>
  
  private var viewStore: ViewStoreOf<RootReducer>
  
  init(store: StoreOf<RootReducer>? = nil) {
    let unwrapStore = store ?? Store(initialState: RootReducer.State()) {
      RootReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
    super.init(nibName: nil, bundle: nil)
  }


  private var viewController = UIViewController() {
    willSet {
      viewController.willMove(toParent: nil)
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
      addChild(newValue)
      newValue.view.frame = self.view.frame
      view.addSubview(newValue.view)
      newValue.didMove(toParent: self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
      //bind view to viewstore
    viewStore.publisher.rootScreen.subscribe(onNext: { [weak self] screen in
      guard let self = self else {return}
      switch screen {
      case .main:
          let vc = MainViewController(store: self.store.scope(state: \.mainState, action: RootReducer.Action.mainAction))
        let nav = UINavigationController(rootViewController: vc)
        self.viewController = nav
      case .auth:
          let vc = AuthViewController(store: self.store.scope(state: \.authState, action: RootReducer.Action.authAction))
        let nav = UINavigationController(rootViewController: vc)
        self.viewController = nav
      }
    })
    .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.viewWillAppear)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.viewWillDisappear)
  }
}

#Preview {
  RootViewController().toSwiftUI()
}
