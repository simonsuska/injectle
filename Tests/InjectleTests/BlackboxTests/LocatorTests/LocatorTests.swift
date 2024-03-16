import XCTest
@testable import Injectle

final class LocatorTests: XCTestCase {
    private var testClass: LocatorTestClass!
    private var locatorClass: LocatorClass!
    private var anotherLocatorClass: LocatorClass!

    override func setUp() {
        self.testClass = LocatorTestClass()
        self.locatorClass = LocatorClass(value: 174)
        self.anotherLocatorClass = LocatorClass(value: 203)
    }
    
    override func tearDown() {
        Injectle.testDown()
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by its type.
    func testInjectTestDetectWithoutKey() {
        Injectle[.default].registerSingleton(self.locatorClass)
        Injectle[.test].registerSingleton(self.anotherLocatorClass)
        
        XCTAssertEqual(self.testClass.concrInjectProperty.someMethod(), 174)
        
        Injectle.testUp()
        XCTAssertEqual(self.testClass.concrInjectProperty.someMethod(), 203)
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by a key.
    func testInjectTestDetectWithKey() {
        Injectle[.default].registerSingleton(self.locatorClass, forKey: LK.liKey)
        Injectle[.test].registerSingleton(self.anotherLocatorClass, forKey: LK.liKey)
        
        XCTAssertEqual(self.testClass.anotherConcrInjectProperty.someMethod(), 174)
        
        Injectle.testUp()
        XCTAssertEqual(self.testClass.anotherConcrInjectProperty.someMethod(), 203)
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by its type.
    func testOptjectTestDetectWithoutKey() {
        Injectle[.default].registerSingleton(self.locatorClass)
        Injectle[.test].registerSingleton(self.anotherLocatorClass)
        
        XCTAssertEqual(self.testClass.concrOptjectProperty?.someMethod(), 174)
        
        Injectle.testUp()
        XCTAssertEqual(self.testClass.concrOptjectProperty?.someMethod(), 203)
    }
    
    /// This test evaluates whether detecting a test case works properly for a service identified by a key.
    func testOptjectTestDetectWithKey() {
        Injectle[.default].registerSingleton(self.locatorClass, forKey: LK.loKey)
        Injectle[.test].registerSingleton(self.anotherLocatorClass, forKey: LK.loKey)
        
        XCTAssertEqual(self.testClass.anotherConcrOptjectProperty?.someMethod(), 174)
        
        Injectle.testUp()
        XCTAssertEqual(self.testClass.anotherConcrOptjectProperty?.someMethod(), 203)
    }
}
