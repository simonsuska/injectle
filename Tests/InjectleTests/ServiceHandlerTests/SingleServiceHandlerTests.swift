import XCTest
import Mockaffee
@testable import Injectle

final class SingleServiceHandlerTests: XCTestCase {
    // These properties are used for testing the unregister mechanism.
    private var scopeMock: ScopeMock!
    private var serviceHandler: SingleServiceHandler!
    
    override func setUp() {
        // Set up necessary stuff to be able to test the unregister mechanism.
        self.scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        self.serviceHandler = SingleServiceHandler(scope: self.scopeMock)
        
        // Request some services that can be unregistered afterwards.
        let _ = self.serviceHandler.requestService(forID: "10")
        let _ = self.serviceHandler.requestService(forID: "20")
        let _ = self.serviceHandler.requestService(forID: "30")
    }
    
    /// This test evaluates whether requesting a service works properly for a `SingleServiceHandler`.
    func testRequestService() {
        let scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        let serviceHandler = SingleServiceHandler(scope: scopeMock)
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "10") as? ServiceHandlerTestClass
        
        // Verify that the singleton is resolved (and a new reference is added to the
        // `references` array).
        verify(on: scopeMock, called: exactly(1)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "20") as? ServiceHandlerTestClass
        
        // Verify that the singleton is resolved (and a new reference is added to the
        // `references` array).
        verify(on: scopeMock, called: exactly(2)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "10") as? ServiceHandlerTestClass
        
        // Verify that the singleton is resolved (and no new reference is added to the
        // `references` array).
        verify(on: scopeMock, called: exactly(3)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "30") as? ServiceHandlerTestClass
        
        // Verify that the singleton is resolved (and a new reference is added to the
        // `references` array).
        verify(on: scopeMock, called: exactly(4)).resolve()
    }
    
    /// This test evaluates whether unregistering a service works properly for
    /// a `SingleServiceHandler` without requesting any service before.
    func testUnregisterServiceInitial() {
        let scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        let serviceHandler = SingleServiceHandler(scope: scopeMock)
        
        let shouldUnregisterServiceHandler = serviceHandler.unregisterService(forID: "10")
        XCTAssertTrue(shouldUnregisterServiceHandler)
    }
    
    /// This test evaluates whether unregistering a service works properly for a `SingleServiceHandler`.
    func testUnregisterService() {
        var shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "20")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "30")
        XCTAssertTrue(shouldUnregisterServiceHandler)
    }
}
