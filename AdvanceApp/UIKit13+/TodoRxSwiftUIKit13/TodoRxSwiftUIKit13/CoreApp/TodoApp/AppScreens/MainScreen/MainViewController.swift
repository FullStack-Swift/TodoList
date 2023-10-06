import ComposableArchitecture
import SwiftUI
import UIKit
import ConvertSwift
import RxCocoa
import RxDataSources

public extension IdentifiedArray {
  func toArray() -> [Element] {
    var array: [Element] = []
    for value in self {
      array.append(value)
    }
    return array
  }
}

enum MultipleSectionModel: SectionModelType {
  
  typealias Item = SectionItem
  
  case buttonReloadSection
  case createTitleSection
  case itemSection(items: [Item])
  
  init(original: MultipleSectionModel, items: [Item]) {
    switch original {
    case .buttonReloadSection:
      self = .buttonReloadSection
    case .createTitleSection:
      self = .createTitleSection
    case .itemSection(_):
      self = .itemSection(items: items)
    }
    self = original
  }
  
  var items: [Item] {
    switch self {
    case .buttonReloadSection:
      return [.buttonReloadSection]
    case .createTitleSection:
      return [.createTitleSection]
    case .itemSection(let items):
      return items
    }
  }
  
  var headerTitle: String? {
    return nil
  }
}

enum SectionItem {
  case buttonReloadSection
  case createTitleSection
  case itemSection(item: TodoModel)
  
  var todoModel: TodoModel? {
    switch self {
    case .buttonReloadSection:
      return nil
    case .createTitleSection:
      return nil
    case .itemSection(let item):
      return item
    }
  }
}

final class MainViewController: UIViewController {
  
  private let store: Store<MainState, MainAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  /// Properties
  private let disposeBag = DisposeBag()
  
  private let tableView: UITableView = UITableView()
  
  private var dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>?
  
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
    // navigationView
    let buttonLogout = UIButton(type: .system)
    buttonLogout.setTitle("Logout", for: .normal)
    buttonLogout.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    buttonLogout.setTitleColor(UIColor(Color.blue), for: .normal)
    let rightBarButtonItem = UIBarButtonItem(customView: buttonLogout)
    
    let buttonCount = UIButton(type: .system)
    buttonCount.setTitle(" +0- ", for: .normal)
    let leftBarButtonItem = UIBarButtonItem(customView: buttonCount)
  
    configureTableView()
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem = rightBarButtonItem
    navigationItem.leftBarButtonItem = leftBarButtonItem
    
    // bind view to viewstore
    buttonLogout.rx.tap
      .map{ViewAction.logout}
      .subscribe(viewStore.action)
      .disposed(by: disposeBag)
    
    buttonCount.rx.tap
      .map{ViewAction.setNavigation(isActive: true)}
      .subscribe(viewStore.action)
      .disposed(by: disposeBag)
    
    // bind viewstore to view
    viewStore.publisher.todos
      .map {$0.count.toString() + " Todos"}
      .bind(to: navigationItem.rx[keyPath: \.title])
      .disposed(by: disposeBag)
    
    store
      .scope(state: \.optionalCounterState, action: MainAction.counterAction)
      .ifLet(
        then: { [weak self] store in
          self?.navigationController?.pushViewController(
            CounterViewController(store: store), animated: true)
        },
        else: { [weak self] in
          guard let self = self else { return }
          self.navigationController?.popToViewController(self, animated: true)
        }
      )
      .disposed(by: disposeBag)

    
    viewStore.publisher.todos
      .map{$0.toArray()}
      .flatMap { items in
        return Observable.just([
          MultipleSectionModel(original: MultipleSectionModel.buttonReloadSection, items: [.buttonReloadSection]),
          MultipleSectionModel(original: MultipleSectionModel.createTitleSection, items: [.createTitleSection]),
          MultipleSectionModel(original: MultipleSectionModel.itemSection(items: items.map({ item in SectionItem.itemSection(item: item)})), items: items.map({ item in SectionItem.itemSection(item: item)}))
        ])
      }
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: self.dataSource!))
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !self.isMovingToParent {
      self.viewStore.send(.setNavigation(isActive: false))
    }
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

// - MARK: UI
private extension MainViewController {
  
  func configureTableView() {
    view.addSubview(tableView)
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.frame = view.frame.insetBy(dx: 10, dy: 10)
    tableView.isUserInteractionEnabled = true
    tableViewRegisterCells()
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel> { [viewStore] dataSource, tableView, indexPath, _ in
      switch dataSource[indexPath.section] {
      case .buttonReloadSection:
        let cell = tableView.dequeueReusableCell(ButtonReloadMainTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        viewStore.publisher.isLoading
          .bind(to: cell.buttonReload.rx[keyPath: \.isHidden])
          .disposed(by: cell.disposeBag)
        viewStore.publisher.isLoading
          .map({!$0})
          .bind(to: cell.activityIndicator.rx[keyPath: \.isHidden])
          .disposed(by: cell.disposeBag)
        return cell
      case .createTitleSection:
        let cell = tableView.dequeueReusableCell(CreateTitleMainTableViewCell.self, for: indexPath)
        viewStore.publisher.title
          .bind(to: cell.titleTextField.rx[keyPath: \.text])
          .disposed(by: cell.disposeBag)
        viewStore.publisher.title.isEmpty
          .map { $0 ? UIColor(Color.gray) : UIColor(Color.green) }
          .subscribe(onNext: {
            cell.buttonCreate.setTitleColor($0, for: .normal)
          })
          .disposed(by: cell.disposeBag)
        cell.buttonCreate.rx.tap
          .map({ViewAction.createTodo})
          .bind(to: viewStore.action)
          .disposed(by: cell.disposeBag)
        cell.titleTextField.rx.text.orEmpty
          .compactMap({$0})
          .map(ViewAction.changeTextFieldTitle)
          .bind(to: viewStore.action)
          .disposed(by: cell.disposeBag)
        return cell
      case let .itemSection(item):
        let cell = tableView.dequeueReusableCell(MainTableViewCell.self, for: indexPath)
        guard let todo = item[indexPath.row].todoModel else {
          return cell
        }
        cell.bind(todo)
        cell.deleteButton
          .rx.tap
          .map{ViewAction.deleteTodo(todo)}
          .bind(to: viewStore.action)
          .disposed(by: cell.disposeBag)
        cell.tapGesture
          .rx.event
          .map {_ in ViewAction.toggleTodo(todo)}
          .bind(to: viewStore.action)
          .disposed(by: cell.disposeBag)
        return cell
      }
    } titleForHeaderInSection: { dataSource, index in
      return dataSource[index].headerTitle
    }
    self.dataSource = dataSource
    tableView.rx.setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  /// tableViewRegisterCells
  func tableViewRegisterCells() {
    tableView.register(MainTableViewCell.self)
    tableView.register(ButtonReloadMainTableViewCell.self)
    tableView.register(CreateTitleMainTableViewCell.self)
  }
}

// - MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

// - MARK: PreviewProvider
struct MainViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = MainViewController()
    vc.toSwifUIView()
  }
}

fileprivate struct ViewState: Equatable {
  var title: String = ""
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

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case viewDeinit
  case none
  case getTodo
  case toggleTodo(TodoModel)
  case createTodo
  case updateTodo(TodoModel)
  case deleteTodo(TodoModel)
  case logout
  case changeTextFieldTitle(String)
  case setNavigation(isActive: Bool)
  /// init ViewAction
  /// - Parameter action: MainAction
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
    case .changeTextFieldTitle(let text):
      self = .changeTextFieldTitle(text)
    case .setNavigation(isActive: let isActive):
      self = .setNavigation(isActive: isActive)
    case .viewDeinit:
      self = .viewDeinit
    default:
      self = .none
    }
  }
}
