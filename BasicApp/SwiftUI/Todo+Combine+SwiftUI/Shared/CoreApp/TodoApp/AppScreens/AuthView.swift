import ComposableArchitecture
import SwiftUI

struct Auth: ReducerProtocol {
  
  // MARK: State
  struct State: Equatable {
    
  }
  
  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case login
    case changeRootScreen(RootScreen)
  }
  
  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .viewOnAppear:
        break
      case .viewOnDisappear:
        break
      case .login:
        return EffectTask(value: .changeRootScreen(.main))
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
    let unwrapStore = store ?? Store(
      initialState: Auth.State(),
      reducer: Auth()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
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

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}
