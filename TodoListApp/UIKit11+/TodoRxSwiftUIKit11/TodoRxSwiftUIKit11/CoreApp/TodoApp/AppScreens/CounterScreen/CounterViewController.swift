import ComposableArchitecture
import Combine
import SwiftUI
import UIKit


final class CounterViewController: UIViewController {
  
  private let store: Store<CounterState, CounterAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private let disposeBag = DisposeBag()
  
  init(store: Store<CounterState, CounterAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: CounterState(), reducer: CounterReducer, environment: CounterEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: CounterAction.init))
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
      // setup view
    if #available(iOS 13.0, *) {
      self.view.backgroundColor = .systemBackground
    } else {
        // Fallback on earlier versions
    }
      /// decrementButton
    let decrementButton = UIButton(type: .system)
    decrementButton.setTitle("−", for: .normal)
      /// countLabel
    let countLabel = UILabel()
    countLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
      /// incrementButton
    let incrementButton = UIButton(type: .system)
    incrementButton.setTitle("+", for: .normal)
    
      /// containerView
    let rootStackView = UIStackView(arrangedSubviews: [
      decrementButton,
      countLabel,
      incrementButton,
    ])
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(rootStackView)
    NSLayoutConstraint.activate([
      rootStackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
      rootStackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
    ])
    
      //bind view to viewstore
    decrementButton.rx.tap
      .map { ViewAction.decrementButtonTapped }
      .subscribe(viewStore.action)
      .disposed(by: disposeBag)
    
    incrementButton.rx.tap
      .map { ViewAction.incrementButtonTapped }
      .subscribe(viewStore.action)
      .disposed(by: disposeBag)
    
      //bind viewstore to view
    self.viewStore.publisher
      .map { $0.count.toString() }
      .bind(to: countLabel.rx.text)
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

fileprivate struct ViewState: Equatable {
  var count = 0
  init(state: CounterState) {
    count = state.count
  }
}

fileprivate enum ViewAction: Equatable {
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case none
  case decrementButtonTapped
  case incrementButtonTapped
  init(action: CounterAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    default:
      self = .none
    }
  }
}

fileprivate extension CounterAction {
  init(action: ViewAction) {
    switch action {
    case .viewDidLoad:
      self = .viewDidLoad
    case .viewWillAppear:
      self = .viewWillAppear
    case .viewWillDisappear:
      self = .viewWillDisappear
    case .decrementButtonTapped:
      self = .decrement
    case .incrementButtonTapped:
      self = .increment
    default:
      self = .none
    }
  }
}
