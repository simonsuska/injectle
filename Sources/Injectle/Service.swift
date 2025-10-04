// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation

/// A type that manages the objects of a scope.
///
/// In the context of the Injectle package, it is used by `Injectle` to be able to
/// manage all services in a central place. New services  are not created directly,
/// but through the appropriate methods of the `Injectle` class.
protocol Service {
    func requestObject(forID id: AnyHashable) -> Any?
    func removeObject(forID id: AnyHashable)
}

/// This type manages the references to a single object.
///
/// In the context of the Injectle package, it is used in combination with `SingletonScope`
/// and `LazySingletonScope` to manage the references pointing to the singleton object
/// in a central place.
final class SingleService: Service {
    
    //: MARK: - PROPERTIES
    
    /// This property stores the scope to request the single object from.
    private let scope: any Scope
    
    /// This property stores the references pointing to the single object.
    private var references: [AnyHashable]
    
    /// This property stores the IDs of the references that have already been removed
    /// through the `removeObject(forID:)` method.
    ///
    /// In the context of the Injectle package, an ID is equal to the UUID of an object 
    /// of the property wrapper `Optject`.
    private var removedIDs: [AnyHashable]
    
    //: MARK: - INITIALIZER
    
    init(scope: any Scope) {
        self.scope = scope
        self.references = []
        self.removedIDs = []
    }
    
    //: MARK: - METHODS
    
    /// This method requests and returns the single object from the scope and stores the given ID
    /// to be a reference to the single object.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrappers `Inject` or `Optject`.
    ///
    /// If the ID to identify the specific reference to the single object has already been removed, this
    /// method returns `nil`. This means that once a property annotated with `@Optject` is assigned
    /// the value `nil`, it no longer has access to the singleton object.
    ///
    /// - Parameter id: An ID to identify a specific reference to the single object uniquely
    /// - Returns: The single object or `nil`, if the ID has already been removed
    func requestObject(forID id: AnyHashable) -> Any? {
        guard !self.removedIDs.contains(id) else {
            return nil
        }
        
        if !self.references.contains(id) {
            self.references.append(id)
        }
        
        return self.scope.resolve()
    }
    
    /// This method removes the reference to the single object for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrapper `Optject`.
    ///
    /// - Important: This method will only be used by `Injectle` when assigning `nil` to an injected
    ///             property which requires using `Optject`.
    /// - Parameter id: The unique ID to the reference that will be removed
    func removeObject(forID id: AnyHashable) {
        if !self.removedIDs.contains(id) {
            self.removedIDs.append(id)
        }
        
        if let referenceIdx = self.references.firstIndex(of: id) {
            self.references.remove(at: referenceIdx)
        }
    }
}

/// This type manages multiple objects of the same scope. Each object is assumed to have only one reference.
///
/// In the context of the Injectle package, it is used in combination with `FactoryScope`
/// to manage all manufactured objects of the same scope in a central place.
final class MultiService: Service {
    
    //: MARK: - PROPERTIES
    
    /// This property stores the scope to request a new object from.
    private let scope: any Scope
    
    /// This property stores the manufactured objects of the given scope.
    private var services: [AnyHashable: Any]
    
    /// This property stores the IDs whose object have already been removed through
    /// the `removeObject(forID:)` method.
    ///
    /// In the context of the Injectle package, an ID is equal to the UUID of an object
    /// of the property wrapper `Optject`.
    private var removedIDs: [AnyHashable]
    
    //: MARK: - INITIALIZER
    
    init(scope: any Scope) {
        self.scope = scope
        self.services = [:]
        self.removedIDs = []
    }
    
    //: MARK: - METHODS
    
    /// This method returns the manufactured object for the given ID. If no object corresponds to the given ID
    /// and the ID has not already been removed, a new object is requested from the scope. If the ID to identify
    /// a manufactured object has already been removed, this method returns `nil`.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrappers `Inject` or `Optject`.
    ///
    /// - Parameter id: An ID to identify a specific object uniquely
    /// - Returns: The object for the given ID or a new object, if no object corresponds to the given ID or
    ///           `nil`, if the ID has already been removed
    func requestObject(forID id: AnyHashable) -> Any? {
        guard !self.removedIDs.contains(id) else {
            return nil
        }
        
        if let service = self.services[id] {
            return service
        } 
        
        let newService = self.scope.resolve()
        self.services[id] = newService
        return newService
    }
    
    /// This method removes the manufactured object for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrapper `Optject`.
    ///
    /// - Important: This method will only be used by `Injectle` when assigning `nil` to an injected
    ///             property which requires using `Optject`.
    /// - Parameter id: The unique ID to the object that will be removed
    func removeObject(forID id: AnyHashable) {
        if !self.removedIDs.contains(id) {
            self.removedIDs.append(id)
        }
        
        self.services[id] = nil
    }
}
