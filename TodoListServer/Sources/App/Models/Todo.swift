import Fluent
import Vapor

final class Todo: Model, Content {
  static let schema = "todos"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "title")
  var title: String
  
  @Field(key: "isCompleted")
  var isCompleted: Bool
  
  init() { }
  
  init(id: UUID? = nil, title: String, isCompleted: Bool) {
    self.id = id
    self.title = title
    self.isCompleted = isCompleted
  }
}
