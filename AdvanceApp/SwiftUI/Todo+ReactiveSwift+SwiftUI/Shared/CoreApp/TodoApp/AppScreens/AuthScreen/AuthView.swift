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
#if os(macOS)
      ZStack {
        switch viewStore.authScreen {
        case .login:
          LoginView(store: store.scope(state: \.loginState, action: AuthAction.loginAction))
        case .register:
          RegisterView(store: store.scope(state: \.registerState, action: AuthAction.registerAction))
        }
      }
      .toolbar {
        ToolbarItem(placement: .status) {
          HStack {
            Button("Login") {
              viewStore.send(.changeAuthScreen(.login))
            }
            Spacer()
            Button("Register") {
              viewStore.send(.changeAuthScreen(.register))
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

#endif
#if os(iOS)
      NavigationView {
        content
        .navigationBarHidden(true)
      }
      .navigationViewStyle(.stack)
#endif
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

extension AuthView {
  private var content: some View {
    VStack {
      ZStack {
        Color.green
        Text("TodoList")
          .bold()
          .font(.title)
          .foregroundColor(.white)
      }
      VStack {
        HStack {
          loginView
          registerView
        }
      }
      .padding()
    }
  }
  
  private var loginView: some View {
    NavigationLink(destination: LoginView(store: store.scope(state: \.loginState, action: AuthAction.loginAction))) {
      ZStack {
        Rectangle()
          .foregroundColor(Color.gray.opacity(0.2))
          .frame(height: 52)
        Text("Login")
          .bold()
          .foregroundColor(Color.black)
      }
    }
  }
  
  private var registerView: some View {
    NavigationLink(destination: RegisterView(store: store.scope(state: \.registerState, action: AuthAction.registerAction))) {
      ZStack {
        Rectangle()
          .frame(height: 52)
          .foregroundColor(Color.black)
        Text("Register")
          .bold()
          .foregroundColor(Color.white)
      }
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}

fileprivate struct ViewState: Equatable {
  var authScreen: AuthScreen = .login
  init(state: AuthState) {
    self.authScreen = state.authScreen
  }
}

fileprivate enum ViewAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case changeAuthScreen(AuthScreen)
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
    case .changeAuthScreen(let screen):
      self = .changeAuthScreen(screen)
    default:
      self = .none
    }
  }
}
