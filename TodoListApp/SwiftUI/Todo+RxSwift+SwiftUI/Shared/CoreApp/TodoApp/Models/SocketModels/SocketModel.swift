import Foundation

struct SocketModel<T>: Codable, Equatable where T: Codable, T: Equatable {
  var socketEvent : SocketEvent
  var value: T
}
