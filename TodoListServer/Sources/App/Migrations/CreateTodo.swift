import Fluent

struct CreateTodo: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("todos")
      .id()
      .field("text", .string, .required)
      .field("isCompleted", .bool, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("todos").delete()
  }
}
