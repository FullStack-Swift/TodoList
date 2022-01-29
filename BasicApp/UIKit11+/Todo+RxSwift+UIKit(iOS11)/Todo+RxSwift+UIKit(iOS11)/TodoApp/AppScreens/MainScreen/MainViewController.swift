import ComposableArchitecture
import UIKit
import ConvertSwift

final class MainViewController: UIViewController {
  
  private let store: Store<MainState, MainAction>
  
  private let viewStore: ViewStore<MainState, MainAction>
  
  private let disposeBag = DisposeBag()
  
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
    buttonLogout.rx.tap
      .map{_ in MainAction.logout}
      .bind(to: viewStore.action)
      .disposed(by: disposeBag)
    
    
    //bind viewstore to view
    viewStore.publisher.todos
      .subscribe { [weak self] event in
        guard let self = self else {return}
        if let element = event.element {
          self.todos = element
          self.tableView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    viewStore.publisher.todos.count
      .map {$0.toString() + " Todos"}
      .bind(to: self.rx.title)
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
        .subscribe { value in
          cell.buttonReload.setTitle(value ? "Loading" : "Reload" , for: .normal)
        }
        .disposed(by: cell.disposeBag)
      cell.buttonReload.rx.tap
        .map {MainAction.getTodo}
        .bind(to: viewStore.action)
        .disposed(by: cell.disposeBag)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
      viewStore.publisher.title
        .bind(to: cell.textFieldTitle.rx.text)
        .disposed(by: cell.disposeBag)
      viewStore.publisher.title.isEmpty
        .bind(to: cell.buttonCreate.rx.isHidden)
        .disposed(by: cell.disposeBag)
      cell.buttonCreate.rx.tap
        .map {MainAction.createTodo}
        .bind(to: viewStore.action)
        .disposed(by: cell.disposeBag)
      cell.textFieldTitle.rx.text.orEmpty
        .map(MainAction.changeText)
        .bind(to: viewStore.action)
        .disposed(by: cell.disposeBag)
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
      let todo = todos[indexPath.row]
      cell.bind(todo)
      cell.deleteButton.rx.tap
        .map{MainAction.deleteTodo(todo)}
        .bind(to: viewStore.action)
        .disposed(by: cell.disposeBag)
      cell.tapGesture.rx.event
        .map {_ in MainAction.toggleTodo(todo)}
        .bind(to: viewStore.action)
        .disposed(by: cell.disposeBag)
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
