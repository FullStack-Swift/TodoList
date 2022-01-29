import Foundation

protocol AnyStorageValue {}

public protocol StorageKey {
  associatedtype Value
}

struct Value<T>: AnyStorageValue {
  var value: T
}

  /// Core type representing a Proj application.
public final class Application {
  public var storage: Storage
  public static let shared = Application()
  public init() {
    self.storage = Storage()
  }
}

public struct Storage {
  var storage: [ObjectIdentifier: AnyStorageValue]
  public init() {
    self.storage = [:]
  }
  public mutating func clear() {
    self.storage = [:]
  }
  public subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: StorageKey {
    get {
      self.get(Key.self)
    }
    set {
      self.set(Key.self, to: newValue)
    }
  }
  public func contains<Key>(_ key: Key.Type) -> Bool {
    self.storage.keys.contains(ObjectIdentifier(Key.self))
  }
  public func get<Key>(_ key: Key.Type) -> Key.Value? where Key: StorageKey {
    guard let value = self.storage[ObjectIdentifier(Key.self)] as? Value<Key.Value> else {
      return nil
    }
    return value.value
  }
  public mutating func set<Key>(_ key: Key.Type, to value: Key.Value?) where Key: StorageKey {
    let key = ObjectIdentifier(Key.self)
    if let value = value {
      self.storage[key] = Value(value: value)
    } else if self.storage[key] != nil {
      self.storage[key] = nil
    }
  }
}
