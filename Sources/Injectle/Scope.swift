import Foundation

/// A type that defines a scope and thus when and how services are created.
///
/// In the context of the Injectle package, it is used by `ServiceHandler` to be able to 
/// manage different services or references of the same scope in a central place. New scopes
/// are not created directly, but through the appropriate methods of the `Injectle` class.
public protocol Scope {
    func resolve() -> Any
}

/// This type represents a factory and thus returns a new service each time one is requested.
public final class FactoryScope: Scope {
    /// This property stores the blueprint of the service to be *manufactured*.
    private let factory: () -> NSCopying
    
    init(factory: @autoclosure @escaping () -> NSCopying) {
        self.factory = factory
    }
    
    /// This method returns a new service which is a copy of the given factory.
    ///
    /// - Returns: A new service which is a copy of the given factory
    public func resolve() -> Any {
        return (self.factory)().copy()
    }
}

/// This type represents a singleton and thus returns the same service each time one is requested.
public final class SingletonScope: Scope {
    private let singleton: Any
    
    init(singleton: Any) {
        self.singleton = singleton
    }
    
    /// This method returns the singleton service.
    ///
    /// - Returns: The singleton service
    public func resolve() -> Any {
        return self.singleton
    }
}

/// This type represents a lazy singleton and thus returns the same service each time one is requested.
/// Since it is a lazy singleton, the service is not created until it is requested the first time.
public final class LazySingletonScope: Scope {
    /// This property stores the blueprint of the lazy singleton service.
    private var factory: () -> Any
    
    /// This property stores the singleton after it is created.
    private var singleton: Any?
    
    init(factory: @autoclosure @escaping () -> Any) {
        self.factory = factory
    }
    
    /// This method returns the singleton service and previously creates it if it did not already exist.
    ///
    /// - Returns: The singleton service
    public func resolve() -> Any {
        if self.singleton == nil {
            self.singleton = (self.factory)()
        }
        
        return self.singleton!
    }
}
