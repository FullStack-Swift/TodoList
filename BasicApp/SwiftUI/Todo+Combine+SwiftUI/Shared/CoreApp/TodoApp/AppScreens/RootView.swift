import ComposableArchitecture
import SwiftUI

struct Root: ReducerProtocol {
  
  // MARK: State
  struct State: Equatable {
    var authState = Auth.State()
    var mainState = Main.State()
    var rootScreen: RootScreen = .main
  }
  
  // MARK: Action
  enum Action: Equatable {
    case authAction(Auth.Action)
    case mainAction(Main.Action)
    case viewOnAppear
    case viewOnDisappear
    case none
    case changeRootScreen(RootScreen)
  }
  
  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
      case .authAction(.changeRootScreen(let screen)):
        return EffectTask(value: .changeRootScreen(screen))
      case .mainAction(.changeRootScreen(let screen)):
        return EffectTask(value: .changeRootScreen(screen))
      case .viewOnAppear:
        break
      case .viewOnDisappear:
        break
      case .changeRootScreen(let screen):
        state.rootScreen = screen
      default:
        break
      }
      return .none
    }
    ._printChanges()
    Scope(state: \.authState, action: /Action.authAction) {
      Auth()
    }
    Scope(state: \.mainState, action: /Action.mainAction) {
      Main()
    }
  }
}

enum RootScreen {
  case main
  case auth
}

struct RootView: View {
  
  private let store: StoreOf<Root>
  
  @ObservedObject
  private var viewStore: ViewStoreOf<Root>
  
  init(store: StoreOf<Root>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: Root.State(),
      reducer: Root()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
      switch viewStore.rootScreen {
      case .main:
        MainView(
          store: store
            .scope(
              state: \.mainState,
              action: Root.Action.mainAction
            )
        )
      case .auth:
        AuthView(
          store: store
            .scope(
              state: \.authState,
              action: Root.Action.authAction
            )
        )
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
#if os(macOS)
    .frame(minWidth: 700, idealWidth: 700, maxWidth: .infinity, minHeight: 500, idealHeight: 500, maxHeight: .infinity, alignment: .center)
#endif
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
