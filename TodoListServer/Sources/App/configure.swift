import Fluent
import FluentSQLiteDriver
import Vapor
var websocketClients: WebsocketClients!
  // configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.databases.use(.sqlite(.memory), as: .sqlite)
  app.migrations.add(CreateTodo())
  try app.autoMigrate().wait()
    // websocket
  websocketClients = WebsocketClients(eventLoop: app.eventLoopGroup.next())
  app.webSocket("todo-list") { request, webSocket in
    webSocket.send("Connected Socket", promise: request.eventLoop.makePromise())
    websocketClients.add(WebSocketClient(id: UUID(), socket: webSocket))
    webSocket.onText { ws, text in
      websocketClients.active.forEach { client in
        client.socket.send(text, promise: request.eventLoop.makePromise())
      }
    }
  }
    // register routes
  try routes(app)
}
