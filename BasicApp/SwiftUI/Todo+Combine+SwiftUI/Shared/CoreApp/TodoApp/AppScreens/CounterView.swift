import ComposableArchitecture
import SwiftUI
import ConvertSwift

struct Counter: ReducerProtocol {
  
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
  var body: some ReducerProtocolOf<Self> {
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
    let unwrapStore = Store(
      initialState: Counter.State(),
      reducer: Counter()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
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

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView()
  }
}
