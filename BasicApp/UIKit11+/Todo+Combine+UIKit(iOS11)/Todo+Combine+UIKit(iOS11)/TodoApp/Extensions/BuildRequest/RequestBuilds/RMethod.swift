import Foundation
import Alamofire

public struct RMethod: RequestBuilderProtocol {
  let httpMethod: HTTPMethod?
  
  public init(_ httpMethod: HTTPMethod) {
    self.httpMethod = httpMethod
  }
  
  public func build(request: inout URLRequest) {
    request.method = self.httpMethod
  }
}
