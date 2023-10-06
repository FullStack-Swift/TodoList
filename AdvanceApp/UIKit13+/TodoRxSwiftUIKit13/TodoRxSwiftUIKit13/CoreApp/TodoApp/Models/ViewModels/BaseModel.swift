import Foundation

public protocol BaseModel: Codable, Identifiable, Equatable {
  
  associatedtype ID
  
  var id: ID { get set }
}

public extension BaseModel {
  func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }
}
