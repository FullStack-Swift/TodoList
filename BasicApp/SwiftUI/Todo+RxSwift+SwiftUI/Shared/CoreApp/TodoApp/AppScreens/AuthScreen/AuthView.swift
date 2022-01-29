import ComposableArchitecture
import SwiftUI

struct AuthView: View {
  
  private let store: Store<AuthState, AuthAction>
  
  @ObservedObject
  private var viewStore: ViewStore<AuthState, AuthAction>
  
  init(store: Store<AuthState, AuthAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: AuthState(), reducer: AuthReducer, environment: AuthEnvironment())
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
