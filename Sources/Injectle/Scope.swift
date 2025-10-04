// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation

/// A type that defines a scope and thus when and how objects are created.
///
/// In the context of the Injectle package, it is used by `Service` to be able to
/// manage different objects or references of the same scope in a central place. New scopes
/// are not created directly, but through the appropriate methods of the `Injectle` class.
public protocol Scope {
    func resolve() -> Any
}

/// This type represents a factory scope and thus returns a new object each time one is requested.
public final class FactoryScope: Scope {
    /// This property stores the blueprint of the object to be manufactured.
    private let factory: () -> NSCopying
    
    init(factory: @escaping () -> NSCopying) {
        self.factory = factory
    }
    
    /// This method returns a new object which is a copy of the given factory.
    ///
    /// - Returns: A new object which is a copy of the given factory
    public func resolve() -> Any {
        return (self.factory)().copy()
    }
}

/// This type represents a singleton scope and thus returns the same object each time one is requested.
public final class SingletonScope: Scope {
    private let singleton: Any
    
    init(singleton: Any) {
        self.singleton = singleton
    }
    
    /// This method returns the singleton object.
    ///
    /// - Returns: The singleton object
    public func resolve() -> Any {
        return self.singleton
    }
}

/// This type represents a lazy singleton scope and thus returns the same object each time one is requested.
/// Since it is a lazy singleton, the object is not created until it is requested the first time.
public final class LazySingletonScope: Scope {
    /// This property stores the blueprint of the lazy singleton object.
    private var factory: () -> Any
    
    /// This property stores the singleton object after it is created.
    private var singleton: Any?
    
    init(factory: @escaping () -> Any) {
        self.factory = factory
    }
    
    /// This method returns the singleton object and previously creates it, if it did not already exist.
    ///
    /// - Returns: The singleton object
    public func resolve() -> Any {
        if self.singleton == nil {
            self.singleton = (self.factory)()
        }
        
        return self.singleton!
    }
}
