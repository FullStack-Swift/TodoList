import Foundation

struct TodoModel: BaseModel {
  var id: UUID
  var title: String
  var isCompleted: Bool
}

import RxDataSources

extension TodoModel: IdentifiableType {
  var identity: String {
    id.toString()
  }
}
