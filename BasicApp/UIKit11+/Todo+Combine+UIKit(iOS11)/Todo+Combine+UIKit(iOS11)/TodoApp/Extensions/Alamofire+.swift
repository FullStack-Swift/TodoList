import ComposableArchitecture
import Alamofire
import Foundation

extension DataRequest {
  public func publisher() -> AnyPublisher<Data?, Never> {
    Effect<Data?, Never>.run { subscriber in
      let request = self.response { response in
        subscriber.send(response.data)
        subscriber.send(completion: .finished)
      }
      return AnyCancellable {
        request.cancel()
      }
    }
    .eraseToAnyPublisher()
  }
}
