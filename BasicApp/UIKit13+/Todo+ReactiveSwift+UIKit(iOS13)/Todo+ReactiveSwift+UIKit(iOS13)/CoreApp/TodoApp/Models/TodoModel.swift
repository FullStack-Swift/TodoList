import Foundation

struct TodoModel: Codable, Identifiable, Equatable {
  var id: UUID
  var text: String
  var isCompleted: Bool
}
