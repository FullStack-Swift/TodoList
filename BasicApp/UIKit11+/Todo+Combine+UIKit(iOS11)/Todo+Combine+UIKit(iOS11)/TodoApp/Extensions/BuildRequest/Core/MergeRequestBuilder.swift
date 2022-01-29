import Foundation

internal struct MergeRequestBuilder: RequestBuilderProtocol {
  fileprivate let children: [RequestBuilderProtocol]
  init(children: [RequestBuilderProtocol] = []) {
    self.children = children
  }
  
  func build(request: inout URLRequest) {
    if children.isEmpty {
      return
    }
    var items: [RequestBuilderProtocol] = []
    //url
    for item in children {
      if item is RUrl {
        items.append(item)
      } else if item is RBaseUrl {
        items.append(item)
      }
      if item is RPath {
        items.append(item)
      }
    }
    // other
    for item in children {
      if !(item is RUrl || item is REncoding) {
        items.append(item)
      }
    }
    // encoding
    for item in children {
      if item is REncoding {
        items.append(item)
      }
    }
    //build
    items.forEach {
      $0.build(request: &request)
    }
  }
}
