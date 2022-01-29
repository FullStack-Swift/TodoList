import Foundation

public struct Rbody: RequestBuilderProtocol {
  var data: Data?
  
  public init(_ data: Data?) {
    self.data = data
  }
  
  public func build(request: inout URLRequest) {
    request.httpBody = data
  }
}
