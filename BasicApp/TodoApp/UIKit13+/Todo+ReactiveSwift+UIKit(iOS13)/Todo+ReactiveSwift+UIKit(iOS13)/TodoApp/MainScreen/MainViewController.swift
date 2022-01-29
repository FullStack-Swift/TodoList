import ComposableArchitecture
import SwiftUI
import UIKit
import ConvertSwift
import ReactiveCocoa

final class MainViewController: UIViewController {
  
  private let store: Store<MainState, MainAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private let tableView: UITableView = UITableView()
  
  private var todos: IdentifiedArrayOf<Todo> = []
  
  var disposables = CompositeDisposable()
  
  init(store: Store<MainState, MainAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: MainState(), reducer: MainReducer, environment: MainEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: MainAction.init))
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
    
    //navigation
    navigationController?.navigationBar.prefersLargeTitles = true
    let buttonLogout = UIButton(type: .system)
    buttonLogout.setTitle("Logout", for: .normal)
    let rightBarButtonItem = UIBarButtonItem(customView: buttonLogout)
    navigationItem.rightBarButtonItem = rightBarButtonItem
    //table
    view.addSubview(tableView)
    tableView.register(MainTableViewCell.self)
    tableView.register(ButtonReloadMainTableViewCell.self)
    tableView.register(CreateTitleMainTableViewCell.self)
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.frame = view.frame.insetBy(dx: 10, dy: 10)
    
    //bind view to viewstore
    disposables += viewStore.action <~ buttonLogout.reactive.controlEvents(.touchUpInside).map {_ in ViewAction.logout}
    //bind viewstore to view
    disposables += viewStore.produced.todos
      .startWithValues({ [weak self] todos in
        guard let self = self else {return}
        self.todos = todos
        self.tableView.reloadData()
      })
    disposables += reactive.title <~ viewStore.produced.todos.count.map {$0.toString() + " Todos"}
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
      return todos.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(ButtonReloadMainTableViewCell.self, for: indexPath)
      cell.disposables += viewStore.action <~ cell.buttonReload.reactive.controlEvents(.touchUpInside).map {_ in ViewAction.getTodo}
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
      cell.disposables += cell.textFieldTitle.reactive.text <~ viewStore.produced.title
      cell.disposables += cell.buttonCreate.reactive.isHidden <~ viewStore.produced.title.isEmpty
      cell.disposables += viewStore.action <~ cell.buttonCreate.reactive.controlEvents(.touchUpInside).map {_ in ViewAction.createTodo}
      cell.disposables += viewStore.action <~ cell.textFieldTitle.reactive.continuousTextValues.map {ViewAction.changeTextFieldTitle($0)}
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      let todo = todos[indexPath.row]
      cell.bind(todo)
      cell.disposables += viewStore.action <~ cell.deleteButton.reactive.controlEvents(.touchUpInside).map {_ in ViewAction.deleteTodo(todo)}
      cell.disposables += viewStore.action <~ cell.tapGesture.reactive.stateChanged.map{_ in ViewAction.toggleTodo(todo)}
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

struct MainViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = MainViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
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

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case logout
  case getTodo
  case toggleTodo(Todo)
  case createTodo
  case deleteTodo(Todo)
  case changeTextFieldTitle(String)
  
  init(action: MainAction) {
    self = .none
  }
}

fileprivate extension MainAction {
  
  init(action: ViewAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    case .changeTextFieldTitle(let value):
      self = .changeTextFieldTitle(value)
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
