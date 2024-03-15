import Foundation

@propertyWrapper public struct Optject<V>: Hashable {
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V? {
        get {
            #warning("TODO: Implement")
            let value: V? = Injectle[.default].getService(forKey: "", requester: uuid)
            return value
        }
        set {
            #warning("TODO: Implement")
        }
    }
    
    private func determineLocator(for filename: StaticString) -> Injectle {
        #warning("TODO: Implement")
        return Injectle[.default]
    }
    
    public init() {
        self.init("")
    }
    
    public init(_ key: AnyHashable) {
        self.uuid = UUID()
        self.key = key
    }
}
