import Fluent
import Vapor

final class Todo: Model, Content {
  static let schema = "todos"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "text")
  var text: String
  
  @Field(key: "isCompleted")
  var isCompleted: Bool
  
  init() { }
  
  init(id: UUID? = nil, text: String, isCompleted: Bool) {
    self.id = id
    self.text = text
    self.isCompleted = isCompleted
  }
}
