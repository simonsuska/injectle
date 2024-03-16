import Foundation

@propertyWrapper public struct Optject<V>: Hashable {
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V? {
        get {
            let value: V? = Injectle.getLocator().getService(forKey: self.key,
                                                             requester: self.uuid)
            return value
        }
        set {
            if let _ = newValue { return }
            Injectle.getLocator().unregister(withKey: self.key, requester: self.uuid)
        }
    }
    
    public init() {
        self.init("\(V.self)")
    }
    
    public init(_ key: AnyHashable) {
        self.uuid = UUID()
        self.key = key
    }
}
