import XCTest
@testable import Injectle

final class InjectTests: XCTestCase {
    private var testClass: InjectTestClass!
    private var injectClass: InjectClass!
    private var anotherInjectClass: AnotherInjectClass!
    private var yetAnotherInjectClass: AnotherInjectClass!
    private var protInjectClass: InjectClass!
    
    override func setUp() {
        Injectle.disableTestDetect()
        
        self.testClass = InjectTestClass()
        self.injectClass = InjectClass(value: 174)
        self.anotherInjectClass = AnotherInjectClass(value: 203)
        self.yetAnotherInjectClass = AnotherInjectClass(value: 403)
        self.protInjectClass = InjectClass(value: 729)
    }
    
    override func tearDown() {
        Injectle.reset()
    }
    
    /// This test evaluates whether registering a factory works properly.
    func testRegisterFactory() {
        Injectle[.default].registerFactory(self.injectClass)
        Injectle[.default].registerFactory(self.anotherInjectClass)
        Injectle[.default].registerFactory(self.yetAnotherInjectClass, forKey: IK.atcKey)
        Injectle[.default].registerFactory(self.protInjectClass, forKey: IK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty.someMethod(), 729)
        
        XCTAssertNotIdentical(self.testClass.concrProperty, self.injectClass)
        XCTAssertNotIdentical(self.testClass.concrPropertyToo, self.injectClass)
        XCTAssertNotIdentical(self.testClass.concrProperty, self.testClass.concrPropertyToo)
        
        XCTAssertNotIdentical(self.testClass.protProperty, self.protInjectClass)
        XCTAssertNotIdentical(self.testClass.anotherProtProperty, self.protInjectClass)
        XCTAssertNotIdentical(self.testClass.protProperty, self.testClass.anotherProtProperty)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
    }
    
    /// This test evaluates whether registering a singleton works properly.
    func testRegisterSingleton() {
        Injectle[.default].registerSingleton(self.injectClass)
        Injectle[.default].registerSingleton(self.anotherInjectClass)
        Injectle[.default].registerSingleton(self.yetAnotherInjectClass, forKey: IK.atcKey)
        Injectle[.default].registerSingleton(self.protInjectClass, forKey: IK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty.someMethod(), 729)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.injectClass)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.injectClass)
        
        XCTAssertIdentical(self.testClass.protProperty, self.protInjectClass)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.protInjectClass)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
    }
    
    /// This test evaluates whether registering a lazy singleton works properly.
    func testRegisterLazySingleton() {
        Injectle[.default].registerLazySingleton(self.injectClass)
        Injectle[.default].registerLazySingleton(self.anotherInjectClass)
        Injectle[.default].registerLazySingleton(self.yetAnotherInjectClass, forKey: IK.atcKey)
        Injectle[.default].registerLazySingleton(self.protInjectClass, forKey: IK.pKey)
        
        XCTAssertEqual(self.testClass.concrProperty.someMethod(), 174)
        XCTAssertEqual(self.testClass.concrPropertyToo.someMethod(), 174)
        XCTAssertEqual(self.testClass.anotherConcrProperty.someMethod(), 203)
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty.someMethod(), 403)
        XCTAssertEqual(self.testClass.protProperty.someMethod(), 729)
        XCTAssertEqual(self.testClass.anotherProtProperty.someMethod(), 729)
        
        XCTAssertNotIdentical(self.testClass.concrProperty, self.injectClass)
        XCTAssertNotIdentical(self.testClass.concrPropertyToo, self.injectClass)
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrPropertyToo)
        
        XCTAssertNotIdentical(self.testClass.protProperty, self.protInjectClass)
        XCTAssertNotIdentical(self.testClass.anotherProtProperty, self.protInjectClass)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.anotherProtProperty)
        
        XCTAssertIdentical(self.testClass.concrProperty, self.testClass.concrProperty)
        XCTAssertIdentical(self.testClass.concrPropertyToo, self.testClass.concrPropertyToo)
        XCTAssertIdentical(self.testClass.anotherConcrProperty, self.testClass.anotherConcrProperty)
        XCTAssertIdentical(self.testClass.yetAnotherConcrProperty, self.testClass.yetAnotherConcrProperty)
        XCTAssertIdentical(self.testClass.protProperty, self.testClass.protProperty)
        XCTAssertIdentical(self.testClass.anotherProtProperty, self.testClass.anotherProtProperty)
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by its type.
    func testTestDetectWithoutKey() {
        Injectle[.default].registerSingleton(self.anotherInjectClass)
        Injectle[.test].registerSingleton(self.yetAnotherInjectClass)
        
        XCTAssertEqual(self.testClass.anotherConcrProperty.someMethod(), 203)
        
        Injectle.enableTestDetect()
        XCTAssertEqual(self.testClass.anotherConcrProperty.someMethod(), 403)
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by a key.
    func testTestDetectWithKey() {
        Injectle[.default].registerSingleton(self.anotherInjectClass, forKey: IK.atcKey)
        Injectle[.test].registerSingleton(self.yetAnotherInjectClass, forKey: IK.atcKey)
        
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty.someMethod(), 203)
        
        Injectle.enableTestDetect()
        XCTAssertEqual(self.testClass.yetAnotherConcrProperty.someMethod(), 403)
    }
}
