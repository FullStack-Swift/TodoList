import ComposableArchitecture
import SwiftUI

struct RegisterView: View {
  
  private let store: Store<RegisterState, RegisterAction>
  
  @ObservedObject
  private var viewStore: ViewStore<ViewState, ViewAction>
  
  init(store: Store<RegisterState, RegisterAction>? = nil) {
    let unwrapStore = store ?? Store(initialState: RegisterState(), reducer: RegisterReducer, environment: RegisterEnvironment())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore.scope(state: ViewState.init, action: RegisterAction.init))
  }
  
  var body: some View {
    ZStack {
      Color.gray.opacity(0.1).ignoresSafeArea()
      VStack {
        Spacer()
          .frame(height: 50)
        HStack {
          Text("Register")
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
          Text("REGISTER")
            .bold()
            .foregroundColor(Color.white)
        }
        .onTapGesture {
          viewStore.send(.register)
        }
        Spacer()
      }
      .padding()
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

struct RegisterView_Previews: PreviewProvider {
  static var previews: some View {
    RegisterView()
  }
}

fileprivate struct ViewState: Equatable {
  init(state: RegisterState) {
    
  }
}

fileprivate enum ViewAction: Equatable {
  case viewOnAppear
  case viewOnDisappear
  case none
  case register
  
  init(action: RegisterAction) {
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

fileprivate extension RegisterState {
  var viewState: ViewState {
    get {
      ViewState(state: self)
    }
    set {
      
    }
  }
}

fileprivate extension RegisterAction {
  init(action: ViewAction) {
    switch action {
    case .viewOnAppear:
      self = .viewOnAppear
    case .viewOnDisappear:
      self = .viewOnDisappear
    case .register:
      self = .registerSuccess
    default:
      self = .none
    }
  }
}
