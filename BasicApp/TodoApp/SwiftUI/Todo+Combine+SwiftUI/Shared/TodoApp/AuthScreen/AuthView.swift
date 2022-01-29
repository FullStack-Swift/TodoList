import ComposableArchitecture
import SwiftUI

struct AuthView: View {
  
  private let store: Store<AuthState, AuthAction>
  
  @ObservedObject
  private var viewStore: ViewStore<ViewState, ViewAction>
  
  init(store: Store<AuthState, AuthAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: AuthState(), reducer: AuthReducer, environment: AuthEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: AuthAction.init))
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

fileprivate struct ViewState: Equatable {
  
  init(state: AuthState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case login
  init(action: AuthAction) {
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

fileprivate extension AuthState {
  
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
      
    }
  }
  
}

fileprivate extension AuthAction {
  
  init(action: ViewAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    case .login:
      self = .login
    default:
      self = .none
    }
  }
}
