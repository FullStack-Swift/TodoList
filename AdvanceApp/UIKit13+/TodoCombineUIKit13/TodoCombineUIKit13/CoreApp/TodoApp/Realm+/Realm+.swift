import RealmSwift

extension Realm.Configuration {
    /// Description
    /// - Returns: Configuration
  static func config() -> Realm.Configuration {
      var config = Realm.Configuration()
      config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("todo.realm")
      return config
  }
  
}

extension Realm {
    /// instance Realm
  static var instance: Realm {
    try! Realm(configuration: Realm.Configuration.config())
  }
}

enum RealmStatus: Int, PersistableEnum, Equatable, CaseIterable, Identifiable, CustomStringConvertible {
  var id: Int { self.rawValue }
  case syncOnline
  case deletedOffline
  case createdOffline
  case updatedOffline
  case none
  
  var description: String {
      switch self {
      case .syncOnline: return "syncOnline"
      case .deletedOffline: return "deletedOffline"
      case .createdOffline: return "createdOffline"
      case .updatedOffline: return "updatedOffline"
      case .none: return "none"
      }
  }
}
