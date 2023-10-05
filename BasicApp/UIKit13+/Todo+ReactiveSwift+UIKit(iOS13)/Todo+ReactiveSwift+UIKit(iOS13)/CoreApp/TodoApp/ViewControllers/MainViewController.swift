import SwiftUI
import UIKit

struct MainReducer: Reducer {
  
  struct State: Equatable {
    var text: String = ""
    var todos: IdentifiedArrayOf<TodoModel> = []
    var isLoading: Bool = false
  }
  
  enum Action {
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
          /// view action
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
              SignalProducer(value: MainReducer.Action.resetText)
              .delay(0.3, on: QueueScheduler.main)
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
            SignalProducer(value: MainReducer.Action.getTodo)
            .delay(0.3, on: QueueScheduler.main)
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
              .producer
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
              .producer
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
              .producer
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
              .producer
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
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
    disposables += viewStore.action <~ buttonLogout.reactive.controlEvents(.touchUpInside).map {_ in MainReducer.Action.logout}
    
    //bind viewstore to view
    disposables += viewStore.publisher.todos.producer
      .startWithValues({ [weak self] _ in
        guard let self = self else {return}
        self.tableView.reloadData()
      })
    disposables += reactive.title <~ viewStore.publisher.todos.count.producer.map {$0.toString() + " Todos"}
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
      cell.disposables += viewStore.publisher.isLoading.producer.startWithValues({ value in
        cell.buttonReload.isHidden = value
        if value {
          cell.activityIndicator.startAnimating()
        } else {
          cell.activityIndicator.stopAnimating()
        }
      })
        cell.disposables += viewStore.action <~ cell.buttonReload.reactive.controlEvents(.touchUpInside).map {_ in MainReducer.Action.viewReloadTodo}
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
      cell.disposables += cell.titleTextField.reactive.text <~ viewStore.publisher.text.producer
      cell.disposables += viewStore.publisher.text.isEmpty.producer.startWithValues { value in
        cell.createButton.setTitleColor(value ? UIColor(Color.gray) : UIColor(Color.green), for: .normal)
      }
        cell.disposables += viewStore.action <~ cell.createButton.reactive.controlEvents(.touchUpInside).map {_ in MainReducer.Action.viewCreateTodo}
        cell.disposables += viewStore.action <~ cell.titleTextField.reactive.continuousTextValues.map {MainReducer.Action.changeText($0)}
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      let todo = viewStore.todos[indexPath.row]
      cell.bind(todo)
        cell.disposables += viewStore.action <~ cell.deleteButton.reactive.controlEvents(.touchUpInside).map { _ in MainReducer.Action.viewDeleteTodo(todo)}
        cell.disposables += viewStore.action <~ cell.tapGesture.reactive.stateChanged.map { _ in MainReducer.Action.viewToggleTodo(todo)}
      return cell
    default:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      return cell
    }
  }
}

extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

#Preview {
  MainViewController().toSwiftUI()
}
