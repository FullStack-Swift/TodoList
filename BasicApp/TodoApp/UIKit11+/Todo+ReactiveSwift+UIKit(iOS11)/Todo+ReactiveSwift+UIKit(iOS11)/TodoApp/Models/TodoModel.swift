import Foundation

struct Todo: Codable, Identifiable, Equatable {
  var id: String?
  var title: String
  var isCompleted: Bool
}
