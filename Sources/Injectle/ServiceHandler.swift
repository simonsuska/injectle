import Foundation

protocol ServiceHandler {
    func requestService(forID id: AnyHashable) -> Any
    func unregisterService(forID id: AnyHashable)
}

final class SingleServiceHandler: ServiceHandler {
    private let scope: any Scope
    private var references: [AnyHashable]
    
    init(scope: any Scope) {
        self.scope = scope
        self.references = []
    }
    
    func requestService(forID id: AnyHashable) -> Any {
        return self.scope.resolve()
    }
    
    func unregisterService(forID id: AnyHashable) {
        #warning("TODO: Implement")
    }
}

final class MultiServiceHandler: ServiceHandler {
    private let scope: any Scope
    private var services: [AnyHashable: Any]
    
    init(scope: any Scope) {
        self.scope = scope
        self.services = [:]
    }
    
    func requestService(forID id: AnyHashable) -> Any {
        #warning("TODO: Implement")
        return services[id]
    }
    
    func unregisterService(forID id: AnyHashable) {
        #warning("TODO: Implement")
    }
}
