import Foundation
import WebSocketKit

open class WebSocketClient {
  open var id: UUID
  open var socket: WebSocket
  
  public init(id: UUID, socket: WebSocket) {
    self.id = id
    self.socket = socket
  }
}

open class WebsocketClients {
  var eventLoop: EventLoop
  var storage: [UUID: WebSocketClient]
  
  var active: [WebSocketClient] {
    self.storage.values.filter { !$0.socket.isClosed }
  }
  
  init(eventLoop: EventLoop, clients: [UUID: WebSocketClient] = [:]) {
    self.eventLoop = eventLoop
    self.storage = clients
  }
  
  func add(_ client: WebSocketClient) {
    self.storage[client.id] = client
  }
  
  func remove(_ client: WebSocketClient) {
    self.storage[client.id] = nil
  }
  
  func find(_ uuid: UUID) -> WebSocketClient? {
    self.storage[uuid]
  }
  
  deinit {
    let futures = self.storage.values.map { $0.socket.close() }
    try! self.eventLoop.flatten(futures).wait()
  }
}
