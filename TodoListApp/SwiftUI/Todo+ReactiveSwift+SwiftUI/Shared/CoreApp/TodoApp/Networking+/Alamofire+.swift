import Alamofire
import Combine

public extension NetworkReachabilityManager {
  
    /// publisher network status
    /// - Returns: publisher NetworkReachabilityStatus
  func publisherNetworkReachabilityStatus() -> AnyPublisher<NetworkReachabilityStatus, Never> {
    let passthroughSubject = PassthroughSubject<NetworkReachabilityStatus, Never>()
    startListening { status in
      passthroughSubject.send(status)
    }
    return passthroughSubject.eraseToAnyPublisher()
  }
    /// publisher network status
    /// - Returns: publisher NetworkStatus
  func publisherNetworkNetworkStatus() -> AnyPublisher<NetworkStatus, Never> {
    publisherNetworkReachabilityStatus().map(\.status).eraseToAnyPublisher()
  }
}

public enum NetworkStatus: Equatable {
  case online
  case offline
  case none
  
  var description: String {
    switch self {
    case .online:
      return "Online"
    case .offline:
      return "Offline"
    case .none:
      return "none"
    }
  }
  
}

public extension NetworkReachabilityManager.NetworkReachabilityStatus {
  var status: NetworkStatus {
    switch self {
    case .reachable:
      return .online
    default:
      return .offline
    }
  }
}
