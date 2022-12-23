import Fluent
import Vapor
import AsyncKit

struct CreateUser: AsyncMigration {
  var name: String { "CreateUser" }
  
  func prepare(on database: Database) async throws {
    try await database.schema("users")
      .id()
      .field("name", .string, .required)
      .field("email", .string, .required)
      .field("password_hash", .string, .required)
      .unique(on: "email")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("users").delete()
  }
  }
