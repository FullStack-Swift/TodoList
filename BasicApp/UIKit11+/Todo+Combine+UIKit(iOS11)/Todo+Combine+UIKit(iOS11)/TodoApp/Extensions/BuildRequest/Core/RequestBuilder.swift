import Foundation

@resultBuilder
public enum RequestBuilder {
  public static func buildBlock(_ components: RequestBuilderProtocol...) -> RequestBuilderProtocol {
    MergeRequestBuilder(children: components)
  }
  
  public static func buildArray(_ components: [RequestBuilderProtocol]) -> RequestBuilderProtocol {
    MergeRequestBuilder(children: components)
  }
  
  public static func buildBlock() -> RequestBuilderProtocol {
    MergeRequestBuilder()
  }
  
  public static func buildEither(first component: RequestBuilderProtocol) -> RequestBuilderProtocol {
    component
  }
  
  public static func buildEither(second component: RequestBuilderProtocol) -> RequestBuilderProtocol {
    component
  }
  
  public static func buildOptional(_ component: RequestBuilderProtocol?) -> RequestBuilderProtocol {
    guard let component = component else {
      return MergeRequestBuilder()
    }
    return component
  }
}


