import ComposableArchitecture
import SwiftUI
import UIKit
import ConvertSwift

final class MainViewController: UIViewController {
  
  private let store: Store<MainState, MainAction>
  
  private let viewStore: ViewStore<MainState, MainAction>
  
  private var cancellables: Set<AnyCancellable> = []
  
  private let tableView: UITableView = UITableView()
  
  private var todos: [Todo] = []
  
  init(store: Store<MainState, MainAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: MainState(), reducer: MainReducer, environment: MainEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
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
    buttonLogout.tapPublisher
      .map{MainAction.logout}
      .subscribe(viewStore.action)
      .store(in: &cancellables)
    
    //bind viewstore to view
    viewStore.publisher.todos
      .sink { [weak self] todos in
        guard let self = self else {
          return
        }
        self.todos = todos
        self.tableView.reloadData()
      }
      .store(in: &cancellables)
    viewStore.publisher.todos.count()
      .map {$0.toString() + " Todos"}
      .assign(to: \.title, on: self)
      .store(in: &cancellables)
    
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
      viewStore.publisher.isLoading
        .sink(receiveValue: { value in
          cell.buttonReload.setTitle(value ? "Loading" : "Reload", for: .normal)
        })
        .store(in: &cancellables)
      cell.buttonReload.tapPublisher
        .map{MainAction.getTodo}
        .subscribe(viewStore.action)
        .store(in: &cell.cancellables)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
      viewStore.publisher.title
        .map {$0}
        .assign(to: \.text, on: cell.textFieldTitle)
        .store(in: &cell.cancellables)
      viewStore.publisher.title.isEmpty
        .assign(to: \.isHidden, on: cell.buttonCreate)
        .store(in: &cell.cancellables)
      cell.buttonCreate.tapPublisher
        .map {MainAction.createTodo}
        .subscribe(viewStore.action)
        .store(in: &cell.cancellables)
      cell.textFieldTitle.textPublisher
        .map{MainAction.changeText($0 ?? "")}
        .subscribe(viewStore.action)
        .store(in: &cell.cancellables)
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      let todo = todos[indexPath.row]
      cell.bind(todo)
      cell.deleteButton.tapPublisher
        .map{MainAction.deleteTodo(todo)}
        .subscribe(viewStore.action)
        .store(in: &cell.cancellables)
      cell.tapGesture.tapPublisher
        .map {_ in MainAction.toggleTodo(todo)}
        .subscribe(viewStore.action)
        .store(in: &cell.cancellables)
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
