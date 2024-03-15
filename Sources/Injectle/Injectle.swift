import Foundation

public func allowReassignment(forKey key: AnyHashable) {}

public func forbidReassignment(forKey key: AnyHashable) throws {
    try Injectle.forbidReassignment(forKey: key)
}

public final class Injectle {
    public enum Locator: Int {
        case `default`
        case test
    }
    
    public enum Affix {
        case prefix(String)
        case suffix(String)
    }
    
    //: MARK: - PROPERTIES
    
    private static let instances = [Injectle(), Injectle()]
    private static var autoUnregisterOnNil = true
    private static var testDetection: Affix?
    
    private var serviceHandlers: [AnyHashable: any ServiceHandler] = [:]
    
    //: MARK: - INITIALIZER
    
    private init() {}
    
    //: MARK: - SUBSCRIPTS
    
    public static subscript(_ locator: Locator) -> Injectle {
        #warning("TODO: Implement")
        return instances[0]
    }
    
    //: MARK: - METHODS
    
    static func allowReassignment(forKey key: AnyHashable) {}
    
    static func forbidReassignment(forKey key: AnyHashable) throws {
        #warning("TODO: Implement")
    }
    
    public static func enableAutoUnregisterOnNil() {
        Self.autoUnregisterOnNil = true
    }
    
    public static func disableAutoUnregisterOnNil() {
        Self.autoUnregisterOnNil = false
    }
    
    public static func enableTestDetect(for affix: Affix = .suffix("Tests")) {
        Self.testDetection = affix
    }
    
    public static func disableTestDetect() {
        Self.testDetection = nil
    }
    
    public static func reset(_ locator: Locator? = nil) {
        #warning("TODO: Implement")
    }
    
    func getService<T>(forKey key: AnyHashable = "\(T.self)", requester: UUID) -> T? {
        #warning("TODO: Implement")
        return nil
    }
    
    public func registerFactory<T>(_ factory: @autoclosure @escaping () -> T,
                                   forKey key: AnyHashable = "\(T.self)",
                                   and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerFactory<T>(_ factory: @autoclosure @escaping () -> T,
                                   forKey key: AnyHashable = "\(T.self)"
    ) {
        #warning("TODO: Implement")
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)",
                                     and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)"
    ) {
        #warning("TODO: Implement")
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)",
                                         and reassign: (AnyHashable) throws -> Void
    ) rethrows {
        #warning("TODO: Implement")
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)"
    ) {
        #warning("TODO: Implement")
    }
    
    public func unregister(withKey key: AnyHashable, requester: UUID) {
        // Optject only
        #warning("TODO: Implement")
    }
    
    public func unregister(withKey key: AnyHashable) {
        #warning("TODO: Implement")
    }
    
    public func unregister<T>(_ type: T.Type) {
        #warning("TODO: Implement")
    }
}
