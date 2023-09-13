import SwiftUI

@main
struct TodoApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

public extension DependencyValues {
  var urlString: String {
    "http://127.0.0.1:8080"
  }
}

public var isUsingPublisher: Bool = true
