import ComposableArchitecture
import Alamofire
import Foundation

extension DataRequest {
  public func publisher() -> AnyPublisher<AFDataResponse<Data?>, Never> {
    Effect<AFDataResponse<Data?>, Never>.run { subscriber in
      let request = self.response { response in
        subscriber.send(response)
        subscriber.send(completion: .finished)
      }
      return AnyCancellable {
        request.cancel()
      }
    }
    .eraseToAnyPublisher()
  }
}

public typealias MRequest = SwiftRequest

final public class SwiftRequest {
  public var urlSessionConfiguration: URLSessionConfiguration?
  public var urlRequest: URLRequest
  public var parameter: RequestBuilderProtocol
  
  public init(urlRequest: URLRequest? = nil,
              urlSessionConfiguration: URLSessionConfiguration? = nil,
              @RequestBuilder builder: () -> RequestBuilderProtocol) {
    self.urlSessionConfiguration = urlSessionConfiguration
    self.urlRequest = urlRequest ?? URLRequest(url: URL(string: "https://")!)
    self.parameter = builder()
    parameter.build(request: &self.urlRequest)
  }
}

public extension SwiftRequest {
  typealias Input = AFDataResponse<Data?>
  
  typealias Output = AFDataResponse<Data?>
  
  typealias Failure = Never
}

extension SwiftRequest: Subscriber {
  public func receive(completion: Subscribers.Completion<Never>) {
  }
  
  public func receive(_ input: Input) -> Subscribers.Demand {
    return .none
  }
  
  public func receive(subscription: Subscription) {
    subscription.request(.max(1))
  }
}

extension SwiftRequest: Publisher {
  public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
    publisher().subscribe(subscriber)
  }
}

extension SwiftRequest {
  public func publisher() -> AnyPublisher<Output, Failure> {
    guard let configuration = self.urlSessionConfiguration else {
      return AF.request(urlRequest).publisher()
    }
    let session = Session(configuration: configuration)
    return session.request(urlRequest).publisher()
  }
}
