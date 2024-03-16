import Foundation

@propertyWrapper public struct Inject<V>: Hashable {
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V {
        get {
            #warning("TODO: Implement")
            let value: V? = Injectle[.default].getService(forKey: "", requester: uuid)
            return value!
        }
    }
    
    private func determineLocator(for filename: StaticString) -> Injectle {
        #warning("TODO: Implement")
        return Injectle[.default]
    }
    
    public init() {
        self.init("\(V.self)")
    }
    
    public init(_ key: AnyHashable) {
        self.uuid = UUID()
        self.key = key
    }
}
