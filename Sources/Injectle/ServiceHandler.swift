import Foundation

/// A type that manages the services of a scope.
///
/// In the context of the Injectle package, it is used by `Injectle` to be able to
/// manage all service handlers in a central place. New service handlers are not created directly,
/// but through the appropriate methods of the `Injectle` class.
protocol ServiceHandler {
    func requestService(forID id: AnyHashable) -> Any
    func unregisterService(forID id: AnyHashable) -> Bool
}

/// This type manages the references to a single service.
///
/// In the context of the Injectle package, it is used in combination with `SingletonScope`
/// and `LazySingletonScope` to manage the references pointing to the singleton
/// in a central place.
final class SingleServiceHandler: ServiceHandler {
    /// This property stores the scope to request the single service from.
    private let scope: any Scope
    
    /// This property stores the references pointing to the single service.
    private var references: [AnyHashable]
    
    init(scope: any Scope) {
        self.scope = scope
        self.references = []
    }
    
    /// This method requests and returns the single service from the scope
    /// and stores the given ID to be a reference to the single service.
    ///
    /// In the context of the Injectle package, the ID is equal to the hash value of an object of the
    /// property wrappers `Inject` or `Optject`, provided with `\.self`.
    ///
    /// - Parameter id: An ID to identify a specific reference to the single service uniquely
    /// - Returns: The single service
    func requestService(forID id: AnyHashable) -> Any {
        if !self.references.contains(id) {
            self.references.append(id)
        }
        
        return self.scope.resolve()
    }
    
    /// This method unregisters (removes) the reference to the single service for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the hash value of an object of the
    /// property wrappers `Inject` or `Optject`, provided with `\.self`.
    ///
    /// If this method returns `true`, this service handler itself, and thus the scope as well, will be
    /// unregistered (deleted) completely. 
    ///
    /// - Important: This method will only be used by `Injectle` when `autoUnregisterOnNil` is
    ///             enabled which requires using `Optject`.
    /// - Parameter id: The unique ID to the reference that will be unregistered (removed)
    /// - Returns: `true` if no more references remain after removal, otherwise `false`.
    func unregisterService(forID id: AnyHashable) -> Bool {
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
    /// This property stores the scope to request a new service from.
    private let scope: any Scope
    
    /// This property stores the *manufactured* services of the given scope.
    private var services: [AnyHashable: Any]
    
    init(scope: any Scope) {
        self.scope = scope
        self.services = [:]
    }
    
    /// This method returns the *manufactured* service for the given ID. If no service corresponds
    /// to the given ID, a new service is requested from the scope.
    ///
    /// In the context of the Injectle package, the ID is equal to the hash value of an object of the
    /// property wrappers `Inject` or `Optject`, provided with `\.self`.
    ///
    /// - Parameter id: An ID to identify a specific service uniquely
    /// - Returns: The service for the given ID or a new service, if no service corresponds to the given ID
    func requestService(forID id: AnyHashable) -> Any {
        if let service = self.services[id] {
            return service
        } 
        
        let newService = self.scope.resolve()
        self.services[id] = newService
        return newService
    }
    
    /// This method unregisters (deletes) the *manufactured* service for the given ID.
    ///
    /// In the context of the Injectle package, the ID is equal to the hash value of an object of the
    /// property wrappers `Inject` or `Optject`, provided with `\.self`.
    ///
    /// - Important: This method will only be used by `Injectle` when `autoUnregisterOnNil` is
    ///             enabled which requires using `Optject`.
    /// - Parameter id: The unique ID to the service that will be unregistered (deleted)
    /// - Returns: Always `false`
    func unregisterService(forID id: AnyHashable) -> Bool {
        self.services[id] = nil
        return false
    }
}
