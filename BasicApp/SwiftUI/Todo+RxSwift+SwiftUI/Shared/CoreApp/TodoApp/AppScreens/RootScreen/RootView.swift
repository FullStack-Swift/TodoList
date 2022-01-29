import ComposableArchitecture
import SwiftUI

struct RootView: View {
  
  private let store: Store<RootState, RootAction>
  
  @ObservedObject
  private var viewStore: ViewStore<RootState, RootAction>
  
  init(store: Store<RootState, RootAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: RootState(), reducer: RootReducer, environment: RootEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
      switch viewStore.rootScreen {
      case .main:
        MainView(store: store.scope(state: \.mainState, action: RootAction.mainAction))
      case .auth:
        AuthView(store: store.scope(state: \.authState, action: RootAction.authAction))
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
