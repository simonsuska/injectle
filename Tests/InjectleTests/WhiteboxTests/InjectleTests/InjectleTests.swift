import XCTest
@testable import Injectle

final class InjectleTests: XCTestCase {
    private final let testServiceUUID = UUID()
    private final let testServiceTooUUID = UUID()
    private final let anotherTestServiceUUID = UUID()
    private final let yetAnotherTestServiceUUID = UUID()
    private final let someAnotherTestServiceUUID = UUID()
    private final let unregisterServiceUUID = UUID()
    
    private final let atcKey = "atcKey"
    private final let uKey = "uKey"
    
    private var testClass: InjectleTestClass!
    private var anotherTestClass: AnotherInjectleTestClass!
    private var yetAnotherTestClass: AnotherInjectleTestClass!
    private var unregisterTestClass: UnregisterInjectleTestClass!
    
    private var testService: InjectleTestClass!
    private var testServiceToo: InjectleTestClass!
    private var anotherTestService: AnotherInjectleTestClass!
    private var yetAnotherTestService: AnotherInjectleTestClass!
    private var someAnotherTestService: AnotherInjectleTestClass!
    private var unregisterTestService: UnregisterInjectleTestClass!
    
    private var testService0: InjectleTestClass!
    private var testServiceToo0: InjectleTestClass!
    private var anotherTestService0: AnotherInjectleTestClass!
    private var yetAnotherTestService0: AnotherInjectleTestClass!
    
    override func setUp() {
        self.testClass = InjectleTestClass(value: 174)
        self.anotherTestClass = AnotherInjectleTestClass(value: 203)
        self.yetAnotherTestClass = AnotherInjectleTestClass(value: 403)
        self.unregisterTestClass = UnregisterInjectleTestClass()
        
        // Setup for `testUnregisterServiceHandlerWithoutKey` 
        // and `testUnregisterServiceHandlerWithKey`
        Injectle[.default].registerSingleton(unregisterTestClass)
        Injectle[.default].registerSingleton(unregisterTestClass, forKey: uKey)
    }
    
    override func tearDown() {
        Injectle.reset()
    }
    
    /// This test evaluates whether registering a factory works properly.
    func testRegisterFactory() {
        // In this case, the test classes is declared separately to be able to assert
        // the identities (see below). However, when using this feature in production,
        // the test classes should be passed to the `FactoryScope` directly to
        // reduce the initialization time at the beginning. Otherwise the objects
        // would be created immediatley.
        Injectle[.default].registerFactory(self.testClass)
        Injectle[.default].registerFactory(self.anotherTestClass)
        Injectle[.default].registerFactory(self.yetAnotherTestClass, forKey: self.atcKey)
        
        self.testService = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertEqual(self.testService?.someMethod(), 174)
        XCTAssertEqual(self.testServiceToo?.someMethod(), 174)
        XCTAssertEqual(self.anotherTestService?.someMethod(), 203)
        XCTAssertEqual(self.yetAnotherTestService.someMethod(), 403)
        
        XCTAssertNotIdentical(self.testService, self.testClass)
        XCTAssertNotIdentical(self.testServiceToo, self.testClass)
        XCTAssertNotIdentical(self.testService, self.testServiceToo)
        
        self.testService0 = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo0 = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService0 = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService0 = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertIdentical(self.testService, self.testService0)
        XCTAssertIdentical(self.testServiceToo, self.testServiceToo0)
        XCTAssertIdentical(self.anotherTestService, self.anotherTestService0)
        XCTAssertIdentical(self.yetAnotherTestService, self.yetAnotherTestService0)
    }
    
    /// This test evaluates whether registering a singleton works properly.
    func testRegisterSingleton() {
        Injectle[.default].registerSingleton(self.testClass)
        Injectle[.default].registerSingleton(self.anotherTestClass)
        Injectle[.default].registerSingleton(self.yetAnotherTestClass, forKey: self.atcKey)
        
        self.testService = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertEqual(self.testService?.someMethod(), 174)
        XCTAssertEqual(self.testServiceToo?.someMethod(), 174)
        XCTAssertEqual(self.anotherTestService?.someMethod(), 203)
        XCTAssertEqual(self.yetAnotherTestService.someMethod(), 403)
        
        XCTAssertIdentical(self.testService, self.testClass)
        XCTAssertIdentical(self.testServiceToo, self.testClass)
        
        self.testService0 = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo0 = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService0 = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService0 = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertIdentical(self.testService, self.testService0)
        XCTAssertIdentical(self.testServiceToo, self.testServiceToo0)
        XCTAssertIdentical(self.anotherTestService, self.anotherTestService0)
        XCTAssertIdentical(self.yetAnotherTestService, self.yetAnotherTestService0)
    }
    
    /// This test evaluates whether registering a lazy singleton works properly.
    func testRegisterLazySingleton() {
        // Only this way, a lazy singleton is created. If the object is created
        // separately and merely the reference is passed later on, it would be
        // nothing but a default singleton. Therefore, the properties are not
        // used in this case.
        Injectle[.default].registerLazySingleton(InjectleTestClass(value: 174))
        Injectle[.default].registerLazySingleton(AnotherInjectleTestClass(value: 203))
        Injectle[.default].registerLazySingleton(AnotherInjectleTestClass(value: 403),
                                                 forKey: self.atcKey)
        
        self.testService = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertEqual(self.testService?.someMethod(), 174)
        XCTAssertEqual(self.testServiceToo?.someMethod(), 174)
        XCTAssertEqual(self.anotherTestService?.someMethod(), 203)
        XCTAssertEqual(self.yetAnotherTestService?.someMethod(), 403)
        
        XCTAssertIdentical(self.testService, self.testServiceToo)
        
        self.testService0 = Injectle[.default].getService(requester: self.testServiceUUID)
        self.testServiceToo0 = Injectle[.default].getService(requester: self.testServiceTooUUID)
        
        self.anotherTestService0 = Injectle[.default].getService(requester: self.anotherTestServiceUUID)
        self.yetAnotherTestService0 = Injectle[.default].getService(forKey: self.atcKey,
                                                                   requester: self.yetAnotherTestServiceUUID)
        
        XCTAssertIdentical(self.testService, self.testService0)
        XCTAssertIdentical(self.testServiceToo, self.testServiceToo0)
        XCTAssertIdentical(self.anotherTestService, self.anotherTestService0)
        XCTAssertIdentical(self.yetAnotherTestService, self.yetAnotherTestService0)
    }
    
    /// This test evaluates whether registering a service with allowed reassignment works properly.
    func testRegisterWithAllowedReassignment() {
        Injectle[.default].registerFactory(self.anotherTestClass)
        
        Injectle[.default].registerSingleton(self.yetAnotherTestClass, and: allowReassignment)
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 403)
        
        Injectle[.default].registerLazySingleton(self.anotherTestClass, and: allowReassignment)
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 203)
        
        Injectle[.default].registerLazySingleton(self.yetAnotherTestClass, and: allowReassignment)
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 403)
    }
    
    /// This test evaluates whether registering a service with forbidden reassignment works properly.
    func testRegisterWithForbiddenReassignment() {
        Injectle[.default].registerFactory(self.anotherTestClass)
        
        XCTAssertThrowsError(try Injectle[.default].registerSingleton(self.yetAnotherTestClass,
                                                                      and: forbidReassignment)
        ) { error in
            if let error = error as? InjectleError {
                XCTAssertEqual(error, InjectleError.forbiddenReassignment)
            }
        }
        
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 203)
        
        XCTAssertThrowsError(try Injectle[.default].registerLazySingleton(self.yetAnotherTestClass,
                                                                          and: forbidReassignment)
        ) { error in
            if let error = error as? InjectleError {
                XCTAssertEqual(error, InjectleError.forbiddenReassignment)
            }
        }
        
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 203)
        
        XCTAssertThrowsError(try Injectle[.default].registerFactory(self.yetAnotherTestClass,
                                                                    and: forbidReassignment)
        ) { error in
            if let error = error as? InjectleError {
                XCTAssertEqual(error, InjectleError.forbiddenReassignment)
            }
        }
        
        self.someAnotherTestService = Injectle[.default].getService(requester: self.someAnotherTestServiceUUID)
        XCTAssertEqual(self.someAnotherTestService.someMethod(), 203)
    }
    
    /// This test evaluates whether unregistering a service, identified by its type, works properly.
    func testUnregisterServiceHandlerWithoutKey() {
        self.unregisterTestService = Injectle[.default].getService(requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
        
        self.unregisterTestService = Injectle[.default].getService(forKey: self.uKey,
                                                                   requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
        
        Injectle[.default].unregister(UnregisterInjectleTestClass.self)
        
        self.unregisterTestService = Injectle[.default].getService(requester: self.unregisterServiceUUID)
        XCTAssertNil(self.unregisterTestService)
        
        self.unregisterTestService = Injectle[.default].getService(forKey: self.uKey,
                                                                   requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
    }
    
    /// This test evaluates whether unregistering a service, identified by a key, works properly.
    func testUnregisterServiceHandlerWithKey() {
        self.unregisterTestService = Injectle[.default].getService(requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
        
        self.unregisterTestService = Injectle[.default].getService(forKey: self.uKey,
                                                                   requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
        
        Injectle[.default].unregister(withKey: self.uKey)
        
        self.unregisterTestService = Injectle[.default].getService(requester: self.unregisterServiceUUID)
        XCTAssertNotNil(self.unregisterTestService)
        
        self.unregisterTestService = Injectle[.default].getService(forKey: self.uKey,
                                                                   requester: self.unregisterServiceUUID)
        XCTAssertNil(self.unregisterTestService)
    }
    
    /// This test evaluates whether resetting the default locator works properly.
    func testResetDefaultLocator() {
        let defaultLocator = Injectle[.default]
        let testLocator = Injectle[.test]
        
        Injectle.reset(.default)
        
        XCTAssertNotIdentical(defaultLocator, Injectle[.default])
        XCTAssertIdentical(testLocator, Injectle[.test])
    }
    
    /// This test evaluates whether resetting the test locator works properly.
    func testResetTestLocator() {
        let defaultLocator = Injectle[.default]
        let testLocator = Injectle[.test]
        
        Injectle.reset(.test)
        
        XCTAssertIdentical(defaultLocator, Injectle[.default])
        XCTAssertNotIdentical(testLocator, Injectle[.test])
    }
    
    /// This test evaluates whether resetting all locators explicitly works properly.
    func testResetDefaultAndTestLocator() {
        let defaultLocator = Injectle[.default]
        let testLocator = Injectle[.test]
        
        Injectle.reset(.default, .test)
        
        XCTAssertNotIdentical(defaultLocator, Injectle[.default])
        XCTAssertNotIdentical(testLocator, Injectle[.test])
    }
    
    /// This test evaluates whether resetting all locators works properly.
    func testResetAllLocators() {
        let defaultLocator = Injectle[.default]
        let testLocator = Injectle[.test]
        
        Injectle.resetAll()
        
        XCTAssertNotIdentical(defaultLocator, Injectle[.default])
        XCTAssertNotIdentical(testLocator, Injectle[.test])
    }
}
