import Foundation

public protocol Scope {
    func resolve() -> Any
}

public final class FactoryScope: Scope {
    private let factory: () -> NSCopying
    
    init(factory: @autoclosure @escaping () -> NSCopying) {
        self.factory = factory
    }
    
    public func resolve() -> Any {
        return (self.factory)().copy()
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
    
    init(factory: @autoclosure @escaping () -> Any) {
        self.factory = factory
    }
    
    public func resolve() -> Any {
        if self.singleton == nil {
            self.singleton = (self.factory)()
        }
        
        return self.singleton!
    }
}
