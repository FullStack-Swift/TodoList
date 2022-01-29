import Foundation
import Alamofire
import ReactiveSwift

extension DataRequest: ReactiveExtensionsProvider {}

extension Reactive where Base: DataRequest {
  
  @discardableResult
  public func response(queue: DispatchQueue = .main) -> SignalProducer<AFDataResponse<Data?>, Never> {
    return SignalProducer{ (observer, disposable) in
      let response = self.base.response(queue: queue) { response in
        observer.send(value: response)
        observer.sendCompleted()
      }
      disposable.observeEnded {
        response.cancel()
      }
    }
  }
}
