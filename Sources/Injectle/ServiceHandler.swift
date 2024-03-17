import Foundation

/// A type that manages the services of a scope.
///
/// In the context of the Injectle package, it is used by `Injectle` to be able to
/// manage all service handlers in a central place. New service handlers are not created directly,
/// but through the appropriate methods of the `Injectle` class.
protocol ServiceHandler {
    func requestService(forID id: AnyHashable) -> Any?
    func unregisterService(forID id: AnyHashable) -> Bool
}

/// This type manages the references to a single service.
///
/// In the context of the Injectle package, it is used in combination with `SingletonScope`
/// and `LazySingletonScope` to manage the references pointing to the singleton
/// in a central place.
final class SingleServiceHandler: ServiceHandler {
    
    //: MARK: - PROPERTIES
    
    /// This property stores the scope to request the single service from.
    private let scope: any Scope
    
    /// This property stores the references pointing to the single service.
    private var references: [AnyHashable]
    
    /// This property stores the IDs of the references that have already been unregistered
    /// through the `unregisterService(forID:)` method.
    ///
    /// In the context of the Injectle package, an ID is equal to the UUID of an object 
    /// of the property wrapper `Optject`.
    private var unregisteredIDs: [AnyHashable]
    
    //: MARK: - INITIALIZER
    
    init(scope: any Scope) {
        self.scope = scope
        self.references = []
        self.unregisteredIDs = []
    }
    
    //: MARK: - METHODS
    
    /// This method requests and returns the single service from the scope and stores the given ID
    /// to be a reference to the single service.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrappers `Inject` or `Optject`.
    ///
    /// If the ID to identify the specific reference to the single serivce
    /// has already been unregistered, this method returns `nil`. This means that once a property annotated
    /// with `@Optject` is assigned the value `nil`, it no longer has access to the singleton.
    ///
    /// - Parameter id: An ID to identify a specific reference to the single service uniquely
    /// - Returns: The single service or `nil`, if the ID has already been unregistered
    func requestService(forID id: AnyHashable) -> Any? {
        guard !self.unregisteredIDs.contains(id) else {
            return nil
        }
        
        if !self.references.contains(id) {
            self.references.append(id)
        }
        
        return self.scope.resolve()
    }
    
    /// This method unregisters (removes) the reference to the single service for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrapper `Optject`.
    ///
    /// If this method returns `true` and `autoUnregisterOnNil` is enabled, this service handler itself, and
    /// thus the scope as well, will be unregistered (deleted) completely. This is the case, for example, if all
    /// properties annotated with `@Optject` and pointing to the same singleton are assigned the value `nil`.
    ///
    /// - Important: This method will only be used by `Injectle` when `autoUnregisterOnNil` is
    ///             enabled which requires using `Optject`.
    /// - Parameter id: The unique ID to the reference that will be unregistered (removed)
    /// - Returns: `true` if no more references remain after removal, otherwise `false`.
    func unregisterService(forID id: AnyHashable) -> Bool {
        if !self.unregisteredIDs.contains(id) {
            self.unregisteredIDs.append(id)
        }
        
        if let referenceIdx = self.references.firstIndex(of: id) {
            self.references.remove(at: referenceIdx)
        }
        
        return self.references.isEmpty
    }
}

/// This type manages multiple services of the same scope. Each service is assumed to have only one reference.
///
/// In the context of the Injectle package, it is used in combination with `FactoryScope`
/// to manage all *manufactured* services of the same scope in a central place.
final class MultiServiceHandler: ServiceHandler {
    
    //: MARK: - PROPERTIES
    
    /// This property stores the scope to request a new service from.
    private let scope: any Scope
    
    /// This property stores the *manufactured* services of the given scope.
    private var services: [AnyHashable: Any]
    
    /// This property stores the IDs whose service has already been unregistered through
    /// the `unregisterService(forID:)` method.
    ///
    /// In the context of the Injectle package, an ID is equal to the UUID of an object
    /// of the property wrapper `Optject`.
    private var unregisteredIDs: [AnyHashable]
    
    //: MARK: - INITIALIZER
    
    init(scope: any Scope) {
        self.scope = scope
        self.services = [:]
        self.unregisteredIDs = []
    }
    
    //: MARK: - METHODS
    
    /// This method returns the *manufactured* service for the given ID. If no service corresponds
    /// to the given ID and the ID has not already been unregistered, a new service is requested from the scope. If
    /// the ID to identify a *manufactured* service has already been unregistered, this method returns `nil`.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrappers `Inject` or `Optject`.
    ///
    /// - Parameter id: An ID to identify a specific service uniquely
    /// - Returns: The service for the given ID or a new service, if no service corresponds to the given ID or
    ///           `nil`, if the ID has already been unregistered
    func requestService(forID id: AnyHashable) -> Any? {
        guard !self.unregisteredIDs.contains(id) else {
            return nil
        }
        
        if let service = self.services[id] {
            return service
        } 
        
        let newService = self.scope.resolve()
        self.services[id] = newService
        return newService
    }
    
    /// This method unregisters (deletes) the *manufactured* service for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the UUID of an object of the
    /// property wrapper `Optject`.
    ///
    /// - Important: This method will only be used by `Injectle` when `autoUnregisterOnNil` is
    ///             enabled which requires using `Optject`.
    /// - Parameter id: The unique ID to the service that will be unregistered (deleted)
    /// - Returns: Always `false`
    func unregisterService(forID id: AnyHashable) -> Bool {
        if !self.unregisteredIDs.contains(id) {
            self.unregisteredIDs.append(id)
        }
        
        self.services[id] = nil
        return false
    }
}
