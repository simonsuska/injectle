import XCTest
@testable import Injectle

final class ScopeTests: XCTestCase {
    /// This test evaluates whether resolving a factory works properly.
    func testResolveFactoryScope() {
        let testClass = ScopeTestClass(value: 174)
        let factoryScope = FactoryScope(factory: testClass)
        
        let factoryTestClass: ScopeTestClass? = factoryScope.resolve() as? ScopeTestClass
        let factoryTestClassToo: ScopeTestClass? = factoryScope.resolve() as? ScopeTestClass
        
        XCTAssertNotNil(factoryTestClass)
        XCTAssertNotNil(factoryTestClassToo)
        
        XCTAssertEqual(factoryTestClass?.someMethod(), 174)
        XCTAssertEqual(factoryTestClassToo?.someMethod(), 174)
        
        XCTAssertNotIdentical(factoryTestClass, testClass)
        XCTAssertNotIdentical(factoryTestClassToo, testClass)
        XCTAssertNotIdentical(factoryTestClass, factoryTestClassToo)
    }
    
    /// This test evaluates whether resolving a singleton works properly.
    func testResolveSingletonScope() {
        let testClass = ScopeTestClass(value: 174)
        let singletonScope = SingletonScope(singleton: testClass)
        
        let singletonTestClass: ScopeTestClass? = singletonScope.resolve() as? ScopeTestClass
        let singletonTestClassToo: ScopeTestClass? = singletonScope.resolve() as? ScopeTestClass
        
        XCTAssertNotNil(singletonTestClass)
        XCTAssertNotNil(singletonTestClassToo)
        
        XCTAssertEqual(singletonTestClass?.someMethod(), 174)
        XCTAssertEqual(singletonTestClassToo?.someMethod(), 174)
        
        XCTAssertIdentical(singletonTestClass, testClass)
        XCTAssertIdentical(singletonTestClassToo, testClass)
    }
    
    /// This test evaluates whether resolving a lazy singleton works properly.
    func testResolveLazySingletonScope() {
        let lazySingletonScope = LazySingletonScope(factory: ScopeTestClass(value: 174))
        
        let lazySingletonTestClass: ScopeTestClass? = lazySingletonScope.resolve() as? ScopeTestClass
        let lazySingletonTestClassToo: ScopeTestClass? = lazySingletonScope.resolve() as? ScopeTestClass
        
        XCTAssertNotNil(lazySingletonTestClass)
        XCTAssertNotNil(lazySingletonTestClassToo)
        
        XCTAssertEqual(lazySingletonTestClass?.someMethod(), 174)
        XCTAssertEqual(lazySingletonTestClassToo?.someMethod(), 174)
        
        XCTAssertIdentical(lazySingletonTestClass, lazySingletonTestClassToo)
    }
}
