import Foundation

public protocol RequestBuilderProtocol {
  func build(request: inout URLRequest)
}
