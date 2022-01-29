import ComposableArchitecture
import Foundation
import CombineRequest
import CombineWebSocket

struct MainEnvironment {
  let urlString: String = "https://todolistappproj.herokuapp.com/todos"
  let status: NetworkReachabilityManager = NetworkReachabilityManager.default!
  init() {
  }
}
