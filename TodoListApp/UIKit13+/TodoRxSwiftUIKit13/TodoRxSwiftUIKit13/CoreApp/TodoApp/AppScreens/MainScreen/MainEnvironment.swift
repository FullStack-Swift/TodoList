import ComposableArchitecture
import Foundation
import RxSwiftRequest
import RxSwiftWebSocket

struct MainEnvironment {
  let urlString: String = "https://todolistappproj.herokuapp.com/todos"
  let status: NetworkReachabilityManager = NetworkReachabilityManager.default!
  init() {
  }
}
