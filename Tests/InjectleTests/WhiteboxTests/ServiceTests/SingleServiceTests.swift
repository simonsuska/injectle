import XCTest
import Mockaffee
@testable import Injectle

final class SingleServiceTests: XCTestCase {
    private var requestSM: ScopeMock!
    private var requestSiS: SingleService!
    
    private var unregisterSM: ScopeMock!
    private var unregisterSH: SingleService!
    
    override func setUp() {
        // Setup for `testRequestService()`
        self.requestSM = ScopeMock(object: ServiceTestClass(value: 174))
        self.requestSiS = SingleService(scope: self.requestSM)
        
        _ = self.requestSiS.unregisterObject(forID: "20")
        
        // Setup for `testUnregisterService()`
        self.unregisterSM = ScopeMock(object: ServiceTestClass(value: 203))
        self.unregisterSH = SingleService(scope: self.unregisterSM)
        
        _ = self.unregisterSH.requestObject(forID: "10")
        _ = self.unregisterSH.requestObject(forID: "20")
        _ = self.unregisterSH.requestObject(forID: "30")
    }
    
    /// This test evaluates whether requesting an object works properly.
    func testRequestObject() {
        var service: ServiceTestClass?
            = self.requestSiS.requestObject(forID: "10") as? ServiceTestClass
        
        verify(on: self.requestSM, called: exactly(1)).resolve()
        XCTAssertNotNil(service)
        
        service = self.requestSiS.requestObject(forID: "20") as? ServiceTestClass
        verify(on: self.requestSM, called: exactly(1)).resolve()
        XCTAssertNil(service)
        
        service = self.requestSiS.requestObject(forID: "30") as? ServiceTestClass
        verify(on: self.requestSM, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
        
        service = self.requestSiS.requestObject(forID: "10") as? ServiceTestClass
        verify(on: self.requestSM, called: exactly(3)).resolve()
        XCTAssertNotNil(service)
    }
    
    /// This test evaluates whether deleting an object works properly.
    func testUnregisterObject() {
        var shouldUnregisterSH = self.unregisterSH.unregisterObject(forID: "10")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterObject(forID: "20")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterObject(forID: "10")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterObject(forID: "30")
        XCTAssertTrue(shouldUnregisterSH)
    }
}
