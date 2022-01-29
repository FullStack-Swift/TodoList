import ComposableArchitecture
import SwiftUI

struct CounterView: View {
  
  private let store: Store<CounterState, CounterAction>
  
  @ObservedObject
  private var viewStore: ViewStore<ViewState, ViewAction>
  
  init(store: Store<CounterState, CounterAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: CounterState(), reducer: CounterReducer, environment: CounterEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: CounterAction.init))
  }
  
  var body: some View {
    ZStack {
      HStack {
        Button {
          viewStore.send(.increment)
        } label: {
          Text("+")
        }
        Text(viewStore.count)
        Button {
          viewStore.send(.decrement)
        } label: {
          Text("-")
        }
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView()
  }
}

fileprivate struct ViewState: Equatable {
  var count: String = ""
  init(state: CounterState) {
    count = state.count.toString()
  }
}

fileprivate enum ViewAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case increment
  case decrement
  init(action: CounterAction) {
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

fileprivate extension CounterState {
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
    }
  }
}

fileprivate extension CounterAction {
  init(action: ViewAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    case .increment:
      self = .increment
    case .decrement:
      self = .decrement
    default:
      self = .none
    }
  }
}
