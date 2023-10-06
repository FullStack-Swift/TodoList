import SwiftUI
import UIKit
import ComposableArchitecture

@main
struct TodoApp: App {
  var body: some Scene {
    WindowGroup {
      let vc = RootViewController()
      vc.toSwifUIView()
    }
  }
}
