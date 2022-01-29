import ComposableArchitecture
import SwiftUI

struct LoginView: View {
  
  private let store: Store<LoginState, LoginAction>
  
  @ObservedObject
  private var viewStore: ViewStore<ViewState, ViewAction>
  
  init(store: Store<LoginState, LoginAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: LoginState(), reducer: LoginReducer, environment: LoginEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: LoginAction.init))
  }
  
  var body: some View {
    ZStack {
      ZStack {
        VStack {
          Spacer()
            .frame(height: 50)
          HStack {
            Text("Log in")
              .font(.largeTitle)
              .bold()
              .foregroundColor(.black)
            Spacer()
          }
          TextField("email", text: .constant(""))
            .padding()
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
          SecureField("password", text: .constant(""))
            .padding()
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
          ZStack {
            Rectangle()
              .fill(Color.blue)
              .frame(height: 52)
            Text("LOG IN")
              .bold()
              .foregroundColor(Color.white)
          }
          .onTapGesture {
            viewStore.send(.login)
          }
          Spacer()
        }
        .padding()
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

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}

fileprivate struct ViewState: Equatable {
  init(state: LoginState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case login
  init(action: LoginAction) {
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

fileprivate extension LoginState {
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
      
    }
  }
}

fileprivate extension LoginAction {
  init(action: ViewAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    case .login:
      self = .loginSuccess
    default:
      self = .none
    }
  }
}
