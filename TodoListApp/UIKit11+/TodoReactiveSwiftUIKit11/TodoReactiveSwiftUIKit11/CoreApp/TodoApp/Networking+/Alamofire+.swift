import Alamofire
import ReactiveSwift

public extension NetworkReachabilityManager {
  
    /// publisher network status
    /// - Returns: publisher NetworkReachabilityStatus
  func publisherNetworkReachabilityStatus() -> SignalProducer<NetworkReachabilityStatus, Never> {
    return SignalProducer{ [weak self] (observer, disposable) in
      self?.startListening { status in
        observer.send(value: status)
        observer.sendCompleted()
      }
      disposable.observeEnded { [weak self] in
        self?.stopListening()
      }
    }
  }
    /// publisher network status
    /// - Returns: publisher NetworkStatus
  func publisherNetworkNetworkStatus() -> SignalProducer<NetworkStatus, Never> {
    publisherNetworkReachabilityStatus().map(\.status)
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
