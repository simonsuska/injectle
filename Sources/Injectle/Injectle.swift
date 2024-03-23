import Foundation

/// This function allows the reassignment when registering a service.
///
/// This function is not intended to be called directly, but should be passed
/// during registration to allow reassignment.
///
/// ```swift
/// Injectle[.default].registerSingleton(SomeClass(), and: allowReassignment)
/// // equal to
/// Injectle[.default].registerSingleton(SomeClass())
/// ```
///
/// - Parameters:
///     * instance: The Injectle instance where the service should be registered
///     * key: The key to uniquely identify the service to be registered
public func allowReassignment(in instance: Injectle, forKey key: AnyHashable) {}

/// This method forbids the reassignment when registering a service.
///
/// This function is not intended to be called directly, but should be passed
/// during registration to forbid reassignment.
///
/// ```swift
/// do {
///     try Injectle[.default].registerSingleton(SomeClass(), and: forbidReassignment)
/// } catch InjectleError.forbiddenReassignment {
///     // React to the error
/// }
/// ```
///
/// - Parameters:
///     * instance: The Injectle instance where the service should be registered
///     * key: The key to uniquely identify the service to be registered
/// - Throws: `InjectleError.forbiddenReassignment`, if a service already exists
///           for the specified key
public func forbidReassignment(in instance: Injectle, forKey key: AnyHashable) throws {
    try Injectle.forbidReassignment(in: instance, forKey: key)
}

/// This type implements a service locator with some extended features.
///
/// The Injectle service locator has two different instances, a default locator and a test locator.
/// 
/// > If you are confused about this implementation, do not worry, you can use Injectle as a normal
///   service locator using only the default instance. The test instance merely offers an additional
///   option for registrations that are only available during testing, which can be convenient.
///
/// **The default locator**
///
/// The default locator is used by default whenever you access a service using `@Inject` or `@Optject`.
/// It is meant to be used in production code. You can access the default locator via a subscript.
///
/// ```swift
/// Injectle[.default]
/// ```
///
/// **The test locator**
///
/// The test locator is meant to be used for tests. It is only accessed by `@Inject` and `@Optject`
/// when calling `testUp()` before. In order for `@Inject` and `@Optject` to access the default locator
/// again, `testDown()` must be called at the end. You can access the test locator via a subscript as well.
///
/// ```swift
/// Injectle[.test]
/// ```
///
/// **Testing with Injectle**
///
/// If you decide to not use the test locator, you may use an if-statement to register different services for
/// testing and production.
///
/// ```swift
/// if testing {
///     Injectle[.default].registerSingleton(SomeClassMock(), forKey: "someClass")
/// } else {
///     Injectle[.default].registerSingleton(SomeClass(), forKey: "someClass")
/// }
/// ```
///
/// However, if you decide to use the test locator, you do not have to use an if-statement but merely
/// the test locator.
///
/// ```swift
/// Injectle[.default].registerSingleton(SomeClass(), forKey: "someClass")
/// Injectle[.test].registerSingleton(SomeClassMock(), forKey: "someClass")
/// ```
///
/// Note that the service of `SomeClass()`  is not overriden by the service of `SomeClassMock()`.
/// Both services are present and used in the appropriate situations.
///
/// To use the registered services in your test, simply call `testUp()` in the `setUp()` method and
/// `testDown()` in the `tearDown()` method.
///
/// ```swift
/// final class SomeTests: XCTestCase {
///     override class func setUp() {
///         Injectle.testUp()
///     }
///
///     override class func testDown() {
///         Injectle.testDown()
///     }
/// }
/// ```
///
/// **Features**
///
/// After accessing a locator, you can ...
/// - ... register new factory services
/// - ... register new singleton services
/// - ... register new lazy singleton services
/// - ... unregister services
///
/// by calling the appropriate methods.
public final class Injectle {
    /// This type declares the available instances of the Injectle service locator. 
    ///
    /// The raw value of each case is equal to the index in the `instances` array which holds the instance.
    public enum Locator: Int {
        case `default` = 0
        case test = 1
    }
    
    //: MARK: - PROPERTIES
    
    private static var instances = [Injectle(), Injectle()]
    
    /// This property stores whether unregistering services or *manufactured* objects is possible by
    /// assigning `nil` when using `@Optject`.
    ///
    /// Be aware that all of the following only applies if `autoUnregisterOnNil` is enabled.
    /// Otherwise, any assignment of `nil` has no effect. This feature is enabled by default.
    ///
    /// **Auto-unregistering a _manufactured_ object**
    ///
    /// When assigning `nil` to a property that holds a reference to a *manufactured* object, the concrete
    /// object is deleted. Accessing such a property again returns `nil` rather than creating a new object.
    /// If all properties of the same factory service are assigned `nil`, the factory service itself  is not deleted.
    ///
    /// ```swift
    /// class SomeClass {
    ///     @Optject var property1: SomeFactoryClass?
    ///     @Optject var property2: SomeFactoryClass?
    ///     @Optject var property3: SomeFactoryClass?
    /// }
    ///
    /// let someClass = SomeClass()
    ///
    /// // Concrete manufactured object of `property1` 
    /// // is deleted, if it exists.
    /// someClass.property1 = nil
    ///
    /// // Accessing it again results in `nil`
    /// someClass.property1
    ///
    /// // Accessing `property2` currently results not 
    /// // in `nil` but in a concrete `manufactured` object.
    /// someClass.property2
    ///
    /// // Concrete manufactured object of `property2` is 
    /// // deleted, if it exists.
    /// someClass.property2 = nil
    ///
    /// // Concrete manufactured object of `property3` is 
    /// // deleted, if it exists.
    /// someClass.property3 = nil
    /// ```
    ///
    /// **Auto-unregistering a singleton object or lazy singleton object**
    ///
    /// When assigning `nil` to a property that holds a reference to a singleton object, only the single reference
    /// is deleted. Accessing such a property again returns `nil` rather than the singleton object.
    /// If all properties of the same singleton service are assigned `nil`, the singleton service itself is deleted.
    /// This deletion is equal to calling either the `unregisterService(withKey:)` or
    /// `unregisterService(_:)` method.
    ///
    /// ```swift
    /// class SomeClass {
    ///     @Optject var property1: SomeSingletonClass?
    ///     @Optject var property2: SomeSingletonClass?
    ///     @Optject var property3: SomeSingletonClass?
    /// }
    ///
    /// let someClass = SomeClass()
    ///
    /// // The reference of `property1` to the singleton object 
    /// // is deleted.
    /// someClass.property1 = nil
    ///
    /// // Accessing it again results in `nil`
    /// someClass.property1
    ///
    /// // Accessing `property2` currently results not in 
    /// // `nil` but in the singleton object.
    /// someClass.property2
    ///
    /// // The reference of `property2` to the singleton object 
    /// // is deleted.
    /// someClass.property2 = nil
    ///
    /// // The reference of `property3` to the singleton object 
    /// // is deleted. Since no more references point to that
    /// // singleton object, the singleton service is deleted as well.
    /// someClass.property3 = nil
    /// ```
    private static var autoUnregisterOnNil = true
    
    /// This property stores whether the test locator should be used or not. 
    ///
    /// If it is `true`, the test locator is used, otherwise the default locator is used.
    /// This property is `false` by default.
    private static var isTest: Bool = false
    
    /// This property stores the services which have been registered through the appropriate methods.
    private var services: [AnyHashable: any Service] = [:]
    
    //: MARK: - INITIALIZER
    
    private init() {}
    
    //: MARK: - SUBSCRIPTS
    
    /// This subscript grants access to a specific locator instance.
    ///
    /// - Parameter locator: The locator instance to obtain
    /// - Returns: The instance of the specified locator
    public static subscript(_ locator: Locator) -> Injectle {
        return instances[locator.rawValue]
    }
    
    //: MARK: - METHODS
    
    /// This method allows the reassignment when registering a service.
    ///
    /// It is called by the top-level `allowReassignment(in:forKey:)` function and is not intended
    /// to be used directly.
    ///
    /// - Parameters:
    ///     * instance: The Injectle instance where the service should be registered
    ///     * key: The key to uniquely identify the service to be registered
    static func allowReassignment(in instance: Injectle, forKey key: AnyHashable) {}
    
    /// This method forbids the reassignment when registering a service.
    ///
    /// It is called by the top-level `forbidReassignment(in:forKey:)` function and is not intended
    /// to be used directly.
    ///
    /// - Parameters:
    ///     * instance: The Injectle instance where the service should be registered
    ///     * key: The key to uniquely identify the service to be registered
    /// - Throws: `InjectleError.forbiddenReassignment`, if a service already exists 
    ///           for the specified key
    static func forbidReassignment(in instance: Injectle, forKey key: AnyHashable) throws {
        let key = instance.extractStringBetweenAngleBrackets(in: key)
        
        if let _ = instance.services[key] {
            throw InjectleError.forbiddenReassignment
        }
    }
    
    /// This method returns the appropriate locator.
    ///
    /// If `isTest` is `false`, the default locator is returned, otherwise the test locator is returned.
    ///
    /// In the context of the Injectle package, it is used by `Inject` and `Optject` to retrieve
    /// the correct locator to ask for an object.
    ///
    /// - Returns: The default locator, if `isTest` is `false`, otherwise the test locator
    static func getLocator() -> Injectle {
        return Self.isTest ? Injectle[.test] : Injectle[.default]
    }
    
    /// This method enables the auto-unregister on `nil` feature.
    public static func enableAutoUnregisterOnNil() {
        Self.autoUnregisterOnNil = true
    }
    
    /// This method disables the auto-unregister on `nil` feature.
    public static func disableAutoUnregisterOnNil() {
        Self.autoUnregisterOnNil = false
    }
    
    /// This method sets the test locator to be used instead of the default locator when accessing services.
    ///
    /// It is usually used in the `setUp()` method of a `XCTestCase`.
    public static func testUp() {
        Self.isTest = true
    }
    
    /// This method sets the default locator to be used instead of the test locator when accessing services.
    ///
    /// It is usually used in the `tearDown()` method of a `XCTestCase`.
    public static func testDown() {
        Self.isTest = false
    }
    
    /// This method resets the specified locators.
    ///
    /// Resetting a locator deletes the instance and creates an entirely new one. Therefore, all
    /// registered services of the specified locators are lost.
    ///
    /// - Parameter locators: The locators to be resetted
    public static func reset(_ locators: Locator...) {
        locators.forEach { locator in
            Self.instances[locator.rawValue] = Injectle()
        }
    }
    
    /// This method resets all locators.
    ///
    /// Resetting a locator deletes the instance and creates an entirely new one. Therefore, all
    /// registered services are lost.
    ///
    /// Calling this method is equal to calling `Injectle.reset(.default, .test)`
    public static func resetAll() {
        Self.reset(.default, .test)
    }
    
    /// This method extracts the string between angle brackets.
    ///
    /// In the context of the Injectle package, it is used by `registerSingleton(_:forKey:and:)` and
    /// `registerLazySingleton(_:forKey:and:)` to always obtain the raw type.
    ///
    /// **Example**
    ///
    /// Typically, the object to create a service with should be passed to the appropriate method directly.
    ///
    /// ```swift
    /// // Intended usage
    /// Injectle[.default].registerSingleton(SomeClass())
    /// Injectle[.default].registerLazySingleton(SomeClass())
    /// ```
    ///
    /// However, of course it is possible, **but not recommended**, to initialize the object separately and
    /// distribute it later on.
    ///
    /// ```swift
    /// // Not recommended!
    /// let someClass = SomeClass()
    /// Injectle[.default].registerSingleton(someClass)
    /// Injectle[.default].registerLazySingleton(someClass)
    /// ```
    ///
    /// Well, with this approach it is possible to declare the `someClass` variable as an Optional and thus the
    /// resolved type is equal to `Optional<SomeClass>` rather than `SomeClass`. To ensure that
    /// Injectle also works in these cases, the `extractStringBetweenAngleBrackets(in:)` method
    /// is used.
    ///
    /// > Obviously, this method is only necessary when no specific key is provided. Furthermore, the
    /// `registerFactory(_:forKey:and:)` method does not use this method because the type parameter
    /// `T` conforms to `NSCopying`.
    ///
    /// - Parameter input: The string to extract from
    /// - Returns: The extracted substring
    private func extractStringBetweenAngleBrackets(in input: AnyHashable) -> AnyHashable {
        if let input = input as? String {
            let pattern = "<(.*?)>"
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: input, range: NSRange(input.startIndex..., 
                                                                  in: input))
            
            if let match = matches.first {
                let range = Range(match.range(at: 1), in: input)!
                return String(input[range])
            }
        }
        
        return input
    }
    
    /// This method returns the object from the service of the specified key for the specified requester.
    ///
    /// In the context of the Injectle package, the requester is equal to the UUID of an object of `Inject` or
    /// `Optject`. It is necessary information for the underlying `Service` in order to return the
    /// same *manufactured* object upon multiple accesses from the same requester.
    ///
    /// - Parameters:
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the receiving variable, which should be equal to the expected object.
    ///     * requester: The UUID of the requester, usually an object of `Inject` or `Optject`
    /// - Returns: The object for the specified key and requester or `nil`, if no service exists.
    func getObject<T>(forKey key: AnyHashable = "\(T.self)", requester: UUID) -> T? {
        return self.services[key]?.requestObject(forID: requester) as? T
    }
    
    /// This method registers a factory service.
    ///
    /// **Service registration**
    ///
    /// To register a factory service, simply call this method on the locator instance
    /// where the service should be registered in.
    ///
    /// ```swift
    /// // With allowed reassignment
    /// Injectle[.default].registerFactory(SomeFactoryClass(), 
    ///                                    and: allowReassignment)
    ///
    /// // With forbidden reassignment
    /// do {
    ///     try Injectle[.default].registerFactory(SomeFactoryClass(),
    ///                                            and: forbidReassignment)
    /// } catch InjectleError.forbiddenReassignment {
    ///     // React to the error
    /// }
    /// ```
    ///
    /// **Object creation**
    ///
    /// For each property, a new object is created that is a copy of the specified one.
    ///
    /// ```swift
    /// class SomeClass {
    ///     // All properties are injected with different objects, 
    ///     // which are a copy of `SomeFactoryClass()`.
    ///     @Inject var property1: SomeFactoryClass
    ///     @Inject var property2: SomeFactoryClass
    ///     @Optject var property3: SomeFactoryClass?
    /// }
    /// ```
    ///
    /// Of course, no new object is created if a single property is called more often. If you want to register 
    /// different services of the same type or use protocols instead of concrete types, you have to use keys.
    ///
    /// Note that in the above example, an object of `SomeFactoryClass` is not created until a property is
    /// accessed for the first time. This is because the `SomeFactoryClass()` object is passed **directly**
    /// to the `registerFactory(_:forKey:and:)` method.
    ///
    /// However, if you initialize the object separately and distribute it later on, a dummy object will be
    /// created immediately, which creates an overhead.
    ///
    /// ```swift
    /// // Bad practice. A dummy object is created 
    /// // which will never be used.
    /// let someFactoryClass = SomeFactoryClass()
    /// Injectle[.default].registerFactory(someFactoryClass, 
    ///                                    and: allowReassignment)
    /// ```
    ///
    /// - Parameters:
    ///     * factory: The factory object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided object.
    ///     * reassign: Whether reassignment is allowed for the specified key. Use the top-level functions
    ///              `allowReassignment(in:forKey:)` and `forbidReassignment(in:forKey:)`
    ///              here.
    /// - Throws: `InjectleError.forbiddenReassignment`, if reassignment is forbidden and a
    ///           service already exists for the specified key
    public func registerFactory<T: NSCopying>(_ factory: @autoclosure @escaping () -> T,
                                              forKey key: AnyHashable = "\(T.self)",
                                              and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        // `extractStringBetweenAngleBrackets(in:)` is not necessary in here, because
        // `T` conforms to `NSCopying`
        
        try reassign(self, key)
        self.services[key] = MultiService(scope: FactoryScope(factory: factory))
    }
    
    /// This method registers a factory service and allows reassignment.
    ///
    /// This method is only a convenience function for `registerFactory(_:forKey:and:)`
    ///
    /// - Parameters:
    ///     * factory: The factory object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided object.
    public func registerFactory<T: NSCopying>(_ factory: @autoclosure @escaping () -> T,
                                              forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerFactory(factory(), forKey: key, and: Injectle.allowReassignment)
    }
    
    /// This method registers a singleton service.
    ///
    /// **Service registration**
    ///
    /// To register a singleton service, simply call this method on the locator instance
    /// where the service should be registered in.
    ///
    /// ```swift
    /// // With allowed reassignment
    /// Injectle[.default].registerSingleton(SomeSingletonClass(),
    ///                                      and: allowReassignment)
    ///
    /// // With forbidden reassignment
    /// do {
    ///     try Injectle[.default].registerSingleton(SomeSingletonClass(),
    ///                                              and: forbidReassignment)
    /// } catch InjectleError.forbiddenReassignment {
    ///     // React to the error
    /// }
    /// ```
    ///
    /// **Object creation**
    ///
    /// The singleton object will be used for each property.
    ///
    /// ```swift
    /// class SomeClass {
    ///     // All properties are injected with the 
    ///     // same singleton object.
    ///     @Inject var property1: SomeSingletonClass
    ///     @Inject var property2: SomeSingletonClass
    ///     @Optject var property3: SomeSingletonClass?
    /// }
    /// ```
    ///
    /// If you want to register different services of the same type or use protocols instead of concrete
    /// types, you have to use keys.
    ///
    /// - Parameters:
    ///     * singleton: The singleton object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided object.
    ///     * reassign: Whether reassignment is allowed for the specified key. Use the top-level functions
    ///              `allowReassignment(in:forKey:)` and `forbidReassignment(in:forKey:)`
    ///              here.
    /// - Throws: `InjectleError.forbiddenReassignment`, if reassignment is forbidden and a
    ///           service already exists for the specified key
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)",
                                     and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        try reassign(self, key)
        self.services[key] = SingleService(scope: SingletonScope(singleton: singleton))
    }
    
    /// This method registers a singleton service and allows reassignment.
    ///
    /// This method is only a convenience function for `registerSingleton(_:forKey:and:)`
    ///
    /// - Parameters:
    ///     * singleton: The singleton object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided service.
    public func registerSingleton<T>(_ singleton: T,
                                     forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerSingleton(singleton, forKey: key, and: Injectle.allowReassignment)
    }
    
    /// This method registers a lazy singleton service.
    ///
    /// **Service registration**
    ///
    /// To register a lazy singleton service, simply call this method on the locator instance
    /// where the service should be registered in.
    ///
    /// ```swift
    /// // With allowed reassignment
    /// Injectle[.default].registerLazySingleton(SomeSingletonClass(),
    ///                                          and: allowReassignment)
    ///
    /// // With forbidden reassignment
    /// do {
    ///     try Injectle[.default].registerLazySingleton(SomeSingletonClass(),
    ///                                                  and: forbidReassignment)
    /// } catch InjectleError.forbiddenReassignment {
    ///     // React to the error
    /// }
    /// ```
    ///
    /// **Object creation**
    ///
    /// The lazy singleton service will be used for each property.
    ///
    /// ```swift
    /// class SomeClass {
    ///     // All properties are injected with the
    ///     // same lazy singleton object.
    ///     @Inject var property1: SomeSingletonClass
    ///     @Inject var property2: SomeSingletonClass
    ///     @Optject var property3: SomeSingletonClass?
    /// }
    /// ```
    ///
    /// If you want to register different services of the same type or use protocols instead of concrete
    /// types, you have to use keys.
    ///
    /// Note that registering lazy singleton services only works properly when passing the object **directly**
    /// to the `registerLazySingleton(_:forKey:and:)` method.
    ///
    /// If you initialize the object separately and distribute it later on, an object will be created immediately.
    /// This approach is equal to registering a normal singleton service, since the object is not created the first
    /// time a property is called, but rather upon registration.
    ///
    /// ```swift
    /// // No lazy singleton service is created, since
    /// // `SomeSingletonClass()` is initialized before.
    /// let someSingletonClass = SomeSingletonClass()
    /// Injectle[.default].registerLazySingleton(someSingletonClass,
    ///                                          and: allowReassignment)
    /// ```
    ///
    /// - Parameters:
    ///     * factory: The lazy singleton object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided object.
    ///     * reassign: Whether reassignment is allowed for the specified key. Use the top-level functions
    ///              `allowReassignment(in:forKey:)` and `forbidReassignment(in:forKey:)`
    ///              here.
    /// - Throws: `InjectleError.forbiddenReassignment`, if reassignment is forbidden and a
    ///           service already exists for the specified key
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)",
                                         and reassign: (Injectle, AnyHashable) throws -> Void
    ) rethrows {
        let key = self.extractStringBetweenAngleBrackets(in: key)
        
        try reassign(self, key)
        self.services[key] = SingleService(scope: LazySingletonScope(factory: factory))
    }
    
    /// This method registers a lazy singleton service and allows reassignment.
    ///
    /// This method is only a convenience function for `registerLazySingleton(_:forKey:and:)`
    ///
    /// - Parameters:
    ///     * factory: The lazy singleton object
    ///     * key: The key to uniquely identify the service. If no key is provided, it is equal to the type
    ///           of the provided object.
    public func registerLazySingleton<T>(_ factory: @autoclosure @escaping () -> T,
                                         forKey key: AnyHashable = "\(T.self)"
    ) {
        self.registerLazySingleton(factory(), forKey: key, and: Injectle.allowReassignment)
    }
    
    /// This method deletes the object from the specified requester in the service of the specified key
    ///
    /// In the context of the Injectle package, the requester is equal to the UUID of an object of `Optject`.
    /// It is necessary information for the underlying `Service` in order to delete only the single
    /// object rather than the whole service. Furthermore, it is only called by an object of `Optject`
    /// when `autoUnregisterOnNil` is enabled.
    ///
    /// - Parameters:
    ///     * key: The key to uniquely identify the service.
    ///     * requester: The UUID of the requester, usually an object of `Optject`,
    ///                to uniquely identify the object
    func unregisterObject(inServiceWithKey key: AnyHashable, for requester: UUID) {
        guard Self.autoUnregisterOnNil else { return }
        
        if let serviceHandler = self.services[key] {
            let response = serviceHandler.unregisterObject(forID: requester)
            
            if response && serviceHandler is SingleService {
                self.services[key] = nil
            }
        }
    }
    
    /// This method unregisters the service for the specified key.
    ///
    /// - Parameter key: The key to uniquely identify the service
    public func unregisterService(withKey key: AnyHashable) {
        self.services[key] = nil
    }
    
    /// This method unregisters the service for the specified type.
    ///
    /// If further services of the same type have been registered using keys, these are not affected.
    ///
    /// - Parameter type: The type of the service to unregister
    public func unregisterService<T>(_ type: T.Type) {
        self.services["\(type)"] = nil
    }
}
