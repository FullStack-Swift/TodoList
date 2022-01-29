import RealmSwift
import Foundation
import ConvertSwift

class RealmTodo: Object, ObjectKeyIdentifiable {
    /// store properties
  @Persisted var _id: UUID
  @Persisted var title: String = ""
  @Persisted var isCompleted: Bool = false
  @Persisted var status: RealmStatus = .none
  
  override class func primaryKey() -> String? {
    "_id"
  }
}

extension TodoModel {
  
    /// Convert TodoModel as RealmTodo
    /// - Returns: RealmTodo
  func asRealmTodo() -> RealmTodo {
    let realm = RealmTodo()
    realm._id = id
    realm.title = title
    realm.isCompleted = isCompleted
    return realm
  }
}

extension Array where Element == TodoModel {
    /// Convert an Array TodoModel to Array RealmModel
    /// - Returns: Array RealmModel
  func asArrayRealmTodo() -> Array<RealmTodo> {
    map {$0.asRealmTodo()}
  }
}

extension RealmTodo {
    /// Convert RealmTodo to TodoModel
    /// - Returns: TodoModel
  func asTodoModel() -> TodoModel {
    let todo = TodoModel(id: _id, title: title, isCompleted: isCompleted)
    return todo
  }
}

extension Array where Element == RealmTodo {
    /// Convert an Array RealmModel to Array TodoModel
    /// - Returns: Array TodoModel
  func asArrayTodo() -> Array<TodoModel> {
    map {$0.asTodoModel()}
  }
}


