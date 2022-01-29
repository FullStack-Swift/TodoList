import SwiftUI

public extension View {
    /// embed view in NavigationView
    /// - Returns: some View
  func embedNavigationView() -> some View {
    NavigationView {
      self
    }
  }
}
