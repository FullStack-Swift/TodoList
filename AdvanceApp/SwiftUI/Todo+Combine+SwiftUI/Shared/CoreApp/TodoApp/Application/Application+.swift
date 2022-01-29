import Foundation

extension Application {
    /// AppEnvironment
  enum AppEnvironment {
    case develop
    case stagging
    case production
  }
}

extension Application {
  struct AppEnvironmentStorageKey: StorageKey {
    typealias Value = AppEnvironment
  }
  
  var appEnvironment: AppEnvironment? {
    get {
      storage.get(AppEnvironmentStorageKey.self)
    }
    set {
      storage.set(AppEnvironmentStorageKey.self, to: newValue)
    }
  }
}

extension Application {
  struct BaseURL: StorageKey {
    typealias Value = String
  }
  
  var url: String? {
    get {
      storage.get(BaseURL.self)
    }
    set {
      storage.set(BaseURL.self, to: newValue)
    }
  }
}
