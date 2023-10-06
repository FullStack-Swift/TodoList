import SwiftUI

struct Counter: Reducer {
  
  // MARK: State
  struct State: Equatable, Identifiable {
    var count: Int = 0
    var id: UUID = UUID()
  }
  
  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case increment
    case decrement
  }
  
  // MARK: Reducer
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .increment:
          state.count += 1
          return .none
        case .decrement:
          state.count -= 1
          return .none
        default:
          return .none
      }
    }
    ._printChanges()
  }
}

struct CounterView: View {
  
  private let store: StoreOf<Counter>
  
  @ObservedObject
  private var viewStore: ViewStoreOf<Counter>
  
  init(store: StoreOf<Counter>? = nil) {
    let unwrapStore = Store(initialState: Counter.State()) {
      Counter()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
  }
  
  var body: some View {
    ZStack {
      HStack {
        Button {
          viewStore.send(.increment)
        } label: {
          Text("+")
        }
        Text(viewStore.count.toString())
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

#Preview {
  CounterView()
}
