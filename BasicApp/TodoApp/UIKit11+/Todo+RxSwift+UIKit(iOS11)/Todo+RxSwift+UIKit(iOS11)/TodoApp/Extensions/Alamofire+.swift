import Foundation
import Alamofire
import RxSwift

extension DataRequest: ReactiveCompatible {}

extension Reactive where Base: DataRequest {
  @discardableResult
  public func response(queue: DispatchQueue = .main) -> Single<AFDataResponse<Data?>> {
    Single.create { [weak base] single in
      let cancellableToken = base?.response(queue: queue) { response in
        single(.success(response)
        )
      }
      return Disposables.create {
        cancellableToken?.cancel()
      }
    }
  }
}
