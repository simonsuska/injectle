import Foundation

/// This type grants access to the registered services of the `Injectle` class.
///
/// Be aware that any assignment, other than `nil`, to properties which are annotated with `@Optject`
/// has no effect. If `autoUnregisterOnNil` is disabled, the assignment of `nil` is meaningless as well.
///
/// After registering a service, you can access it by annotating a property with `@Optject`.
///
/// ```swift
/// class SomeClass {
///     // This property will be injected with an object of the
///     // registered service of the concrete type `SomeConcreteType`
///     // or `nil`, if no service exists.
///     @Optject var someProperty: SomeConcreteType?
/// }
/// ```
///
/// If you want to register different services of the same type or use protocols instead of concrete types, you
/// have to use keys.
///
/// ```swift
/// class SomeClass {
///     // This property will be injected with an object of the
///     // registered service of the concrete type `SomeConcreteType`
///     // or `nil`, if no service exists.
///     @Optject var someProperty: SomeConcreteType?
///
///     // This property will be injected with an object of the
///     registered service of the concrete type `SomeConcreteType`,
///     // which has the key "some-key", or `nil`, if
///     // no service exists.
///     @Optject("some-key") var anotherProperty: SomeConcreteType?
///
///     // This property will be injected with an object of a
///     // registered service that conforms to `SomeProtocol`,
///     // which has the key "another-key", or `nil`, if
///     // no service exists.
///     @Optject("another-key") var yetAnotherProperty: any SomeProtocol?
/// }
/// ```
///
/// When choosing keys, you have to consider the four following aspects:
/// 1. The key must not be equal to the name of a type.
/// 2. The key must not contain `<` and `>`.
/// 3. The key must conform to the `Hashable` protocol.
/// 4. The key must be unique across all registered types.
///
/// If no service is registered for the specified type or key, the property is assigned `nil`.
///
/// - Important: This property wrapper is only applicable to Optionals. If you are using
///             non-optional types, use `Inject` instead.
@propertyWrapper public struct Optject<V> {
    
    // MARK: - PROPERTIES
    
    /// This property stores the UUID for a specific property wrapper. It is especially used by
    /// `Service` to differentiate requesters and thus be able to manage the objects.
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V? {
        get {
            let value: V? = Injectle.getLocator().getObject(forKey: self.key,
                                                             requester: self.uuid)
            return value
        }
        set {
            if let _ = newValue { return }
            Injectle.getLocator().unregisterObject(inServiceWithKey: self.key, 
                                                   for: self.uuid)
        }
    }
    
    // MARK: - INITIALIZER
    
    public init() {
        self.init("\(V.self)")
    }
    
    public init(_ key: AnyHashable) {
        self.uuid = UUID()
        self.key = key
    }
}
