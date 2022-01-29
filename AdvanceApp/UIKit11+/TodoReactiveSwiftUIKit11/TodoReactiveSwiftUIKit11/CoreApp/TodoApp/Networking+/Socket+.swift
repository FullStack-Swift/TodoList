import ReactiveSwiftWebSocket
import ComposableArchitecture

extension WebSocketEvent: Equatable {
  public static func == (lhs: WebSocketEvent, rhs: WebSocketEvent) -> Bool {
    switch (lhs, rhs) {
    case (.connected, connected):
      return (/WebSocketEvent.connected).extract(from: lhs) == (/WebSocketEvent.connected).extract(from: rhs)
    case (.disconnected, .disconnected):
      let rhsValue = (/WebSocketEvent.disconnected).extract(from: lhs)
      let lhsValue = (/WebSocketEvent.disconnected).extract(from: rhs)
      return (rhsValue?.0 == lhsValue?.0) && (rhsValue?.1 == lhsValue?.1)
    case (.text, .text):
      return (/WebSocketEvent.text).extract(from: lhs) == (/WebSocketEvent.text).extract(from: rhs)
    case (.binary, .binary):
      return (/WebSocketEvent.binary).extract(from: lhs) == (/WebSocketEvent.binary).extract(from: rhs)
    case (.pong, .pong):
      return (/WebSocketEvent.pong).extract(from: lhs) == (/WebSocketEvent.pong).extract(from: rhs)
    case (.ping, .ping):
      return (/WebSocketEvent.ping).extract(from: lhs) == (/WebSocketEvent.ping).extract(from: rhs)
    case (.error, .error):
      return (/WebSocketEvent.error).extract(from: lhs)! == (/WebSocketEvent.error).extract(from: rhs)!
    case (.viabilityChanged, .viabilityChanged):
      return (/WebSocketEvent.viabilityChanged).extract(from: lhs) == (/WebSocketEvent.viabilityChanged).extract(from: rhs)
    case (.reconnectSuggested, .reconnectSuggested):
      return (/WebSocketEvent.reconnectSuggested).extract(from: lhs) == (/WebSocketEvent.reconnectSuggested).extract(from: rhs)
    case (.cancelled, .cancelled):
      return true
    default:
      return false
    }
  }
}

enum SocketEvent: Equatable, Codable {
  case deleted
  case updated
  case created
}
