import Foundation

@resultBuilder
public enum ArrayRequestBuilder<Element> {
  public static func buildBlock(_ components: Element...) -> [Element] {
    components
  }
}
