import Foundation

final public class CreateRequest {
  private var parameter: RequestBuilderProtocol
  private var urlRequest: URLRequest
  
  public init(
    urlRequest: URLRequest? = nil,
    @RequestBuilder builder: () -> RequestBuilderProtocol
  ) {
    self.urlRequest = urlRequest ?? URLRequest(url: URL(string: "https://")!)
    self.parameter = builder()
    parameter.build(request: &self.urlRequest)
  }
  
  public var value: URLRequest {
    urlRequest
  }
}
