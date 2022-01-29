import Foundation

public struct RPath: RequestBuilderProtocol {
  let path: String?
  
  public init(path: String?) {
    self.path = path
  }
  
  public func build(request: inout URLRequest) {
    guard let urlString = request.url?.absoluteString else {
      return
    }
    guard let path = path else {
      return
    }
    request.url = URL(string: (urlString + "/" + path))
  }
}
