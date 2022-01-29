import Alamofire
import RxSwift

public extension NetworkReachabilityManager {
  
    /// publisher network status
    /// - Returns: publisher NetworkReachabilityStatus
  func publisherNetworkReachabilityStatus() -> Observable<NetworkReachabilityStatus> {
    let publisher = PublishSubject<NetworkReachabilityStatus>()
    startListening { status in
      publisher.onNext(status)
    }
    return publisher.asObservable()
  }
    /// publisher network status
    /// - Returns: publisher NetworkStatus
  func publisherNetworkNetworkStatus() -> Observable<NetworkStatus> {
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
