import OpenCombine
import Alamofire
import Foundation
import ComposableArchitecture
import ConvertSwift
import Json

extension DataRequest {
  public func ocPublishResponse() -> AnyPublisher<Data?, Never> {
    Effect<Data?, Never>.run { subscriber in
      let request = self.response { response in
        subscriber.send(response.data)
        print(response.data?.toJson() as Any)
      }
      return AnyCancellable {
        request.cancel()
      }
    }
    .eraseToAnyPublisher()
  }
}
