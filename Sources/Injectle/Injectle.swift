import Foundation

public final class Injectle {
    public enum Locator: Int {
        case `default`
        case test
    }
    
    private static let instances = [Injectle(), Injectle()]
    public static var autoUnregisterOnNil = true
    
    private var serviceHandlers: [AnyHashable: any ServiceHandler] = [:]
    
    private init() {}
    
    public static subscript(_ locator: Locator) -> Injectle {
        #warning("TODO: Implement")
        return instances[0]
    }
    
    func getService<T>(forKey key: AnyHashable,
                       requester: KeyPath<Inject<Any>, Inject<Any>>
    ) -> T? {
        #warning("TODO: Implement")
        return nil
    }
    
    public func allowReassignment(forKey key: AnyHashable) {}
    
    public func forbidReassignment(forKey key: AnyHashable) throws {
        #warning("TODO: Implement")
    }
    
    public func registerFactory<T>(_ factory: @autoclosure @escaping () -> T,
                                   forKey key: AnyHashable,
                                   and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerFactory<T>(_ factory: @autoclosure @escaping () -> T,
                                   forKey key: AnyHashable
    ) {
        #warning("TODO: Implement")
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable,
                                     and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable
    ) {
        #warning("TODO: Implement")
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable,
                                         and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable
    ) {
        #warning("TODO: Implement")
    }
    
    public func unregister(withKey key: AnyHashable, 
                           requester: KeyPath<Inject<Any>, Inject<Any>>
    ) {
        #warning("TODO: Implement")
    }
    
    public func unregister(withKey key: AnyHashable) {
        #warning("TODO: Implement")
    }
}
