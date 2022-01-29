import Foundation
import Alamofire

public struct REncoding: RequestBuilderProtocol {
  let encoding: ParameterEncoding
  
  public init(_ type: RTypeEncoding = .url) {
    switch type {
    case .json:
      encoding = JSONEncoding.default
    case .url:
      encoding = URLEncoding.default
    }
  }
  
  public func build(request: inout URLRequest) {
    let parameter = request.httpBody?.toDictionary()
    if let newRequest = try? encoding.encode(request, with: parameter) {
      request = newRequest
    }
  }
}

public enum RTypeEncoding {
  case json
  case url
}

extension Data {
  func toDictionary() -> [String: Any]? {
    do {
      let json = try JSONSerialization.jsonObject(with: self)
      return json as? [String: Any]
    } catch {
      return nil
    }
  }
}
