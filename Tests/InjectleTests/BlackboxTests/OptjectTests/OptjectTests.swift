import XCTest
@testable import Injectle

final class OptjectTests: XCTestCase {
    private var testClass: OptjectTestClass!
    private var optjectClass: OptjectClass!
    private var anotherOptjectClass: AnotherOptjectClass!
    private var yetAnotherOptjectClass: AnotherOptjectClass!
    private var protOptjectClass: OptjectClass!
    private var unregisterOptjectClass: UnregisterOptjectClass!
    
    override func setUp() {
        Injectle.enableAutoUnregisterOnNil()
        
        self.testClass = OptjectTestClass()
        self.optjectClass = OptjectClass(value: 174)
        self.anotherOptjectClass = AnotherOptjectClass(value: 203)
        self.yetAnotherOptjectClass = AnotherOptjectClass(value: 403)
        self.protOptjectClass = OptjectClass(value: 729)
        self.unregisterOptjectClass = UnregisterOptjectClass()
    }
    
    override func tearDown() {
        Injectle.reset()
    }
    
    /// This test evaluates whether registering a factory works properly.
    func testRegisterFactory() {
        // In this case, the test classes are declared separately to be able to assert
        // the identities (see below). However, when using this feature in production,
        // the test classes should be passed to the `FactoryScope` directly to
        // reduce the initialization time at the beginning. Otherwise the objects
        // would be created immediatley.
        Injectle[.default].registerFactory(self.optjectClass)
        Injectle[.default].registerFactory(self.anotherOptjectClass)
        Injectle[.default].registerFactory(self.yetAnotherOptjectClass, forKey: OK.atcKey)
        Injectle[.default].registerFactory(self.protOptjectClass, forKey: OK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty?.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo?.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty?.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty?.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty?.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty?.someMethod(), 729)
        
        XCTAssertNotIdentical(self.testClass.concrProperty, self.optjectClass)
        XCTAssertNotIdentical(self.testClass.concrPropertyToo, self.optjectClass)
        XCTAssertNotIdentical(self.testClass.concrProperty, self.testClass.concrPropertyToo)
        
        XCTAssertNotIdentical(self.testClass.protProperty, self.protOptjectClass)
        XCTAssertNotIdentical(self.testClass.anotherProtProperty, self.protOptjectClass)
        XCTAssertNotIdentical(self.testClass.protProperty, self.testClass.anotherProtProperty)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
        
        XCTAssertNil(self.testClass.emptyProperty)
    }
    
    /// This test evaluates whether registering a singleton works properly.
    func testRegisterSingleton() {
        Injectle[.default].registerSingleton(self.optjectClass)
        Injectle[.default].registerSingleton(self.anotherOptjectClass)
        Injectle[.default].registerSingleton(self.yetAnotherOptjectClass, forKey: OK.atcKey)
        Injectle[.default].registerSingleton(self.protOptjectClass, forKey: OK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty?.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo?.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty?.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty?.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty?.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty?.someMethod(), 729)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.optjectClass)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.optjectClass)
        
        XCTAssertIdentical(self.testClass.protProperty, self.protOptjectClass)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.protOptjectClass)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
        
        XCTAssertNil(self.testClass.emptyProperty)
    }
    
    /// This test evaluates whether registering a lazy singleton works properly.
    func testRegisterLazySingleton() {
        // Only this way, a lazy singleton is created. If the object is created
        // separately and merely the reference is passed later on, it would be
        // nothing but a default singleton. Therefore, the properties are not
        // used in this case.
        Injectle[.default].registerLazySingleton(OptjectClass(value: 174))
        Injectle[.default].registerLazySingleton(AnotherOptjectClass(value: 203))
        Injectle[.default].registerLazySingleton(AnotherOptjectClass(value: 403), forKey: OK.atcKey)
        Injectle[.default].registerLazySingleton(OptjectClass(value: 729), forKey: OK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty?.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo?.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty?.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty?.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty?.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty?.someMethod(), 729)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.anotherProtProperty)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
        
        XCTAssertNil(self.testClass.emptyProperty)
    }
    
    /// This test evaluates whether auto-unregistering a `SingleServiceHandler` works properly.
    func testAutoUnregisterSingleServiceHandlerOnNil() {
        Injectle[.default].registerSingleton(self.unregisterOptjectClass)
        
        XCTAssertNotNil(self.testClass.unregisterProperty)
        XCTAssertNotNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        
        self.testClass.unregisterProperty = nil

        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNotNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                      and: forbidReassignment))
        
        self.testClass.unregisterPropertyToo = nil
        
        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                      and: forbidReassignment))
        
        self.testClass.unregisterPropertyAgain = nil
        
        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNil(self.testClass.unregisterPropertyToo)
        XCTAssertNil(self.testClass.unregisterPropertyAgain)
        XCTAssertNoThrow(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                  and: forbidReassignment))
    }
    
    /// This test evaluates whether auto-unregistering a `MultiServiceHandler` works properly.
    func testAutoUnregisterMultiServiceHandlerOnNil() {
        Injectle[.default].registerFactory(self.unregisterOptjectClass)
        
        XCTAssertNotNil(self.testClass.unregisterProperty)
        XCTAssertNotNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        
        self.testClass.unregisterProperty = nil

        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNotNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                      and: forbidReassignment))
        
        self.testClass.unregisterPropertyToo = nil
        
        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNil(self.testClass.unregisterPropertyToo)
        XCTAssertNotNil(self.testClass.unregisterPropertyAgain)
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                      and: forbidReassignment))
        
        self.testClass.unregisterPropertyAgain = nil
        
        XCTAssertNil(self.testClass.unregisterProperty)
        XCTAssertNil(self.testClass.unregisterPropertyToo)
        XCTAssertNil(self.testClass.unregisterPropertyAgain)
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.unregisterOptjectClass,
                                                                      and: forbidReassignment))
    }
    
    /// This test evaluates whether auto-unregistering a `SingleServiceHandler` works properly, if disabled.
    func testAutoUnregisterSingleServiceHandlerOnNilDisabled() {
        Injectle.disableAutoUnregisterOnNil()
        Injectle[.default].registerSingleton(self.unregisterOptjectClass)
    
        XCTAssertNotNil(self.testClass.unregisterProperty)
        self.testClass.unregisterProperty = nil
        XCTAssertNotNil(self.testClass.unregisterProperty)
    }
    
    /// This test evaluates whether auto-unregistering a `MultiServiceHandler` works properly, if disabled.
    func testAutoUnregisterMultiServiceHandlerOnNilDisabled() {
        Injectle.disableAutoUnregisterOnNil()
        Injectle[.default].registerFactory(self.unregisterOptjectClass)
    
        XCTAssertNotNil(self.testClass.unregisterProperty)
        self.testClass.unregisterProperty = nil
        XCTAssertNotNil(self.testClass.unregisterProperty)
    }
}
