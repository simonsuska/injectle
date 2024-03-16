import Foundation

public func allowReassignment(in instance: Injectle, forKey key: AnyHashable) {}

public func forbidReassignment(in instance: Injectle, forKey key: AnyHashable) throws {
    try Injectle.forbidReassignment(in: instance, forKey: key)
}

public final class Injectle {
    public enum Locator: Int {
        case `default` = 0
        case test = 1
    }
    
    public enum Affix {
        case prefix(String)
        case suffix(String)
    }
    
    //: MARK: - PROPERTIES
    
    private static var instances = [Injectle(), Injectle()]
    private static var autoUnregisterOnNil = true
    private static var testDetection: Affix? = .suffix("Tests")
    
    private var serviceHandlers: [AnyHashable: any ServiceHandler] = [:]
    
    //: MARK: - INITIALIZER
    
    private init() {}
    
    //: MARK: - SUBSCRIPTS
    
    public static subscript(_ locator: Locator) -> Injectle {
        return instances[locator.rawValue]
    }
    
    //: MARK: - METHODS
    
    static func allowReassignment(in instance: Injectle, forKey key: AnyHashable) {}
    
    static func forbidReassignment(in instance: Injectle, forKey key: AnyHashable) throws {
        let key = instance.extractStringBetweenAngleBrackets(in: key)
        
        if let _ = instance.serviceHandlers[key] {
            throw InjectleError.forbiddenReassignment
        }
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
    
    public static func reset(_ locators: Locator...) {
        locators.forEach { locator in
            Self.instances[locator.rawValue] = Injectle()
        }
    }
    
    public static func resetAll() {
        Self.reset(.default, .test)
    }
    
    private func extractStringBetweenAngleBrackets(in input: AnyHashable) -> AnyHashable {
        if let input = input as? String {
            let pattern = "<(.*?)>"
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
            
            if let match = matches.first {
                let range = Range(match.range(at: 1), in: input)!
                return String(input[range])
            }
        }
        
        return input
    }
    
    func getService<T>(forKey key: AnyHashable = "\(T.self)", requester: UUID) -> T? {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        return self.serviceHandlers[key]?.requestService(forID: requester) as? T
    }
    
    public func registerFactory<T: NSCopying>(_ factory: @autoclosure @escaping () -> T,
                                              forKey key: AnyHashable = "\(T.self)",
                                              and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        try reassign(self, key)
        self.serviceHandlers[key] = MultiServiceHandler(scope: FactoryScope(factory: factory))
    }
    
    public func registerFactory<T: NSCopying>(_ factory: @autoclosure @escaping () -> T,
                                              forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerFactory(factory(), forKey: key, and: Injectle.allowReassignment)
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)",
                                     and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        try reassign(self, key)
        self.serviceHandlers[key] = SingleServiceHandler(scope: SingletonScope(singleton: singleton))
    }
    
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerSingleton(singleton, forKey: key, and: Injectle.allowReassignment)
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)",
                                         and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        try reassign(self, key)
        self.serviceHandlers[key] = SingleServiceHandler(scope: LazySingletonScope(factory: factory))
    }
    
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerLazySingleton(factory(), forKey: key, and: Injectle.allowReassignment)
    }
    
    public func unregister(withKey key: AnyHashable, requester: UUID) {
        // Optject only
        
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        if let serviceHandler = self.serviceHandlers[key] {
            let response = serviceHandler.unregisterService(forID: requester)
            
            if response && serviceHandler is SingleServiceHandler {
                self.serviceHandlers[key] = nil
            }
        }
    }
    
    public func unregister(withKey key: AnyHashable) {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        self.serviceHandlers[key] = nil
    }
    
    public func unregister<T>(_ type: T.Type) {
        let key = self.extractStringBetweenAngleBrackets(in: "\(type)")
        self.serviceHandlers[key] = nil
    }
}
