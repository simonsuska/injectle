import Foundation

public protocol Scope {
    func resolve() -> Any
}

public final class FactoryScope: Scope {
    private let factory: () -> Any
    
    init(factory: @autoclosure @escaping () -> Any) {
        self.factory = factory
    }
    
    public func resolve() -> Any {
        return (self.factory)()
    }
}

public final class SingletonScope: Scope {
    private let singleton: Any
    
    init(singleton: Any) {
        self.singleton = singleton
    }
    
    public func resolve() -> Any {
        return self.singleton
    }
}

public final class LazySingletonScope: Scope {
    private var factory: () -> Any
    private var singleton: Any?
    
    init(factory: @escaping () -> Any) {
        self.factory = factory
    }
    
    public func resolve() -> Any {
        #warning("TODO: Implement")
        return singleton!
    }
}
