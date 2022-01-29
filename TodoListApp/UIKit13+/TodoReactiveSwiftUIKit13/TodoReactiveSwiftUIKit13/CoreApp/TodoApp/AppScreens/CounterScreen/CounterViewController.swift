import ComposableArchitecture
import ReactiveCocoa
import SwiftUI
import UIKit


final class CounterViewController: UIViewController {
  
  private let store: Store<CounterState, CounterAction>
  
  private let viewStore: ViewStore<ViewState, ViewAction>
  
  private var disposables = CompositeDisposable()
  
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
    self.view.backgroundColor = .systemBackground
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
    disposables += viewStore.action <~ decrementButton.reactive.controlEvents(.touchUpInside)
      .map {_ in ViewAction.decrementButtonTapped }
    
    disposables += viewStore.action <~ incrementButton.reactive.controlEvents(.touchUpInside)
      .map {_ in ViewAction.incrementButtonTapped }
    
      //bind viewstore to view
    disposables += countLabel.reactive.text <~ viewStore.publisher.count.producer.map { $0.toString() }
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

struct CounterViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = CounterViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
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
