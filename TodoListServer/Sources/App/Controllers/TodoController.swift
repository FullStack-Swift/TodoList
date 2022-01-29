import Fluent
import Vapor

struct TodoController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let todos = routes.grouped("todos")
    todos.get(use: index)
    todos.post(use: create)
    todos.delete(":todoID", use: delete(req:))
    todos.post(":todoID", use: update(req:))
  }
  
  func index(req: Request) throws -> EventLoopFuture<[Todo]> {
    return Todo.query(on: req.db).all()
  }
  
  func create(req: Request) throws -> EventLoopFuture<Todo> {
    let todo = try req.content.decode(Todo.self)
    return todo.save(on: req.db).map { todo }
  }
  
  func update(req: Request) throws -> EventLoopFuture<Todo> {
    let update = try req.content.decode(Todo.self)
    return Todo.find(req.parameters.get("todoID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { todo in
      todo.isCompleted = update.isCompleted
      todo.title = update.title
      return todo.save(on: req.db).map({update})
    }
  }
  
  func delete(req: Request) throws -> EventLoopFuture<Todo> {
    return Todo.find(req.parameters.get("todoID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { todo in
        todo.delete(on: req.db).map {todo} }
  }
}
