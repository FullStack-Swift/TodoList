import Foundation
import Alamofire

public struct RHeaders: RequestBuilderProtocol {
  let headers: HTTPHeaders
  
  public init(headers: HTTPHeaders) {
    self.headers = headers
  }
  
  public func build(request: inout URLRequest) {
    request.allHTTPHeaderFields = headers.dictionary
  }
}
