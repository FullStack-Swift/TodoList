import SwiftUI
import UIKit
import Combine

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
              Just<Action>(.resetText)
              .delay(for: 0.3, scheduler: UIScheduler.shared)
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
            Just<Action>(.getTodo)
              .delay(for: 0.3, scheduler: UIScheduler.shared)
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

final class MainViewController: BaseViewController {
  
  private let store: StoreOf<MainReducer>
  
  private var viewStore: ViewStoreOf<MainReducer>
  
  init(store: StoreOf<MainReducer>? = nil) {
    let unwrapStore = store ?? Store(initialState: MainReducer.State()) {
      MainReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
    super.init(nibName: nil, bundle: nil)
  }
  
  private let tableView: UITableView = UITableView()
  
  private let action = PassthroughSubject<MainReducer.Action, Never>()
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
    
    action.sink { [weak self] sendAction in
      self?.viewStore.send(sendAction)
    }
    .store(in: &cancellables)
    
    // navigationView
    let buttonLogout = UIButton(type: .system)
    buttonLogout.setTitle("Logout", for: .normal)
    buttonLogout.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    buttonLogout.setTitleColor(UIColor(Color.blue), for: .normal)
    let rightBarButtonItem = UIBarButtonItem(customView: buttonLogout)
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem = rightBarButtonItem
    // tableView
    view.addSubview(tableView)
    tableView.register(MainTableViewCell.self)
    tableView.register(ButtonReloadMainTableViewCell.self)
    tableView.register(CreateTitleMainTableViewCell.self)
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.isUserInteractionEnabled = true
    // contraint
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10)
    ])

    //bind view to viewstore
    buttonLogout.tapPublisher
      .map{MainReducer.Action.logout}
//      .subscribe(viewStore.action)
      .subscribe(action)
      .store(in: &cancellables)
    
    //bind viewstore to view
    viewStore.publisher.todos
      .sink { [weak self] _ in
        guard let self = self else {
          return
        }
        self.tableView.reloadData()
      }
      .store(in: &cancellables)
    
    viewStore.publisher.todos
      .map {$0.count.toString() + " Todos"}
      .assign(to: \.navigationItem.title, on: self)
      .store(in: &cancellables)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.viewWillAppear)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.viewWillDisappear)
  }
  
  deinit {
    viewStore.send(.viewDeinit)
  }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 1
    case 2:
      return viewStore.todos.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(ButtonReloadMainTableViewCell.self, for: indexPath)
      cell.selectionStyle = .none
      viewStore.publisher.isLoading
        .sink(receiveValue: { value in
          cell.buttonReload.isHidden = value
          if value {
            cell.activityIndicator.startAnimating()
          } else {
            cell.activityIndicator.stopAnimating()
          }
        })
        .store(in: &cell.cancellables)
      cell.buttonReload
        .tapPublisher
        .map{MainReducer.Action.viewReloadTodo}
//        .subscribe(viewStore.action)
        .subscribe(action)
        .store(in: &cell.cancellables)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
      viewStore.publisher.text
        .map {$0}
        .assign(to: \.text, on: cell.titleTextField)
        .store(in: &cell.cancellables)
      viewStore.publisher.text.isEmpty
        .sink(receiveValue: { value in
          cell.createButton.setTitleColor(value ? UIColor(Color.gray) : UIColor(Color.green), for: .normal)
        })
        .store(in: &cell.cancellables)
      cell.createButton
        .tapPublisher
        .map {MainReducer.Action.viewCreateTodo}
//        .subscribe(viewStore.action)
        .subscribe(action)
        .store(in: &cell.cancellables)
      cell.titleTextField
        .textPublisher
        .compactMap{$0}
        .map{MainReducer.Action.changeText($0)}
//        .subscribe(viewStore.action)
        .subscribe(action)
        .store(in: &cell.cancellables)
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      let todo = viewStore.todos[indexPath.row]
      cell.bind(todo)
      cell.deleteButton
        .tapPublisher
        .map{MainReducer.Action.viewDeleteTodo(todo)}
//        .subscribe(viewStore.action)
        .subscribe(action)
        .store(in: &cell.cancellables)
      cell.tapGesture
        .tapPublisher
        .map {_ in MainReducer.Action.viewToggleTodo(todo)}
//        .subscribe(viewStore.action)
        .subscribe(action)
        .store(in: &cell.cancellables)
      return cell
    default:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      return cell
    }
  }
}

  // MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

#Preview {
  MainViewController().toSwiftUI()
}
