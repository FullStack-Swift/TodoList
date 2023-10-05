import SwiftUI
@_exported import ComposableArchitecture
@_exported import MRxSwiftRequest
@_exported import RxCocoa
@_exported import RxSwift
@_exported import Transform

@main
struct TodoApp: App {
  var body: some Scene {
    WindowGroup {
      RootViewController().toSwiftUI()
    }
  }
}

public extension DependencyValues {
  var urlString: String {
    "http://127.0.0.1:8080/todos"
  }
}

public var isUsingPublisher: Bool = true
