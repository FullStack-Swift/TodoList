import ComposableArchitecture
import Foundation
import ReactiveSwiftRequest
import ReactiveSwiftWebSocket

struct MainEnvironment {
  let urlString: String = "https://todolistappproj.herokuapp.com/todos"
  let status: NetworkReachabilityManager = NetworkReachabilityManager.default!
  init() {
  }
}
