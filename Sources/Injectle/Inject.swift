import Foundation

@propertyWrapper public struct Inject<V>: Hashable {
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V {
        get {
            let value: V? = Injectle.getLocator().getService(forKey: self.key,
                                                             requester: self.uuid)
            
            guard let value = value else {
                fatalError("Unexpectedly found nil while requesting" +
                           "a service for key \(key)")
            }
            
            return value
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
