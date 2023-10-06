import SwiftUI
@_exported import ComposableArchitecture
@_exported import MCombineRequest
@_exported import Combine
@_exported import CombineCocoa
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
