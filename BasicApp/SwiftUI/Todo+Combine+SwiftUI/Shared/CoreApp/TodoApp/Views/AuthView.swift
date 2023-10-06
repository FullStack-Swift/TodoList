import SwiftUI

struct Auth: Reducer {
  
  // MARK: State
  struct State: Equatable {
    
  }
  
  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case login
    case changeRootScreen(Root.RootScreen)
  }
  
  // MARK: Reducer
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .viewOnAppear:
        break
      case .viewOnDisappear:
        break
      case .login:
        return .send(.changeRootScreen(.main))
      default:
        break
      }
      return .none
    }
    ._printChanges()
  }
}

struct AuthView: View {
  
  private let store: StoreOf<Auth>
  
  @ObservedObject
  private var viewStore: ViewStoreOf<Auth>
  
  init(store: StoreOf<Auth>? = nil) {
    let unwrapStore = store ?? Store(initialState: Auth.State()) {
      Auth()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore, observe: {$0})
  }
  
  var body: some View {
    ZStack {
      Button("Login") {
        viewStore.send(.login)
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
  AuthView()
}
