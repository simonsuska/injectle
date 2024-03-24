import Foundation

/// This type grants access to the registered services of the `Injectle` class.
///
/// Be aware that properties which are annotated with `@Inject` are not settable afterwards.
/// 
/// **Access to services**
///
/// A registered service can be accessed by annotating a property with `@Inject`.
///
/// ```swift
/// class SomeClass {
///     // This property will be injected with an object
///     // of the concrete type `SomeConcreteType`.
///     @Inject var someProperty: SomeConcreteType
/// }
/// ```
///
/// If no service is registered for the specified type or key, an fatal error is raised.
///
/// **Keys**
///
/// Keys must be used in order to register different services of the same type or use protocols instead of
/// concrete types.
///
/// ```swift
/// class SomeClass {
///     // This property will be injected with an object
///     // of the concrete type `SomeConcreteType`.
///     @Inject var someProperty: SomeConcreteType
///
///     // This property will be injected with an object
///     // of the concrete type `SomeConcreteType` of the
///     // service which has the key "some-key".
///     @Inject("some-key") var anotherProperty: SomeConcreteType
///
///     // This property will be injected with an object
///     // that conforms to `SomeProtocol` of the
///     // service which has the key "another-key".
///     @Inject("another-key") var yetAnotherProperty: any SomeProtocol
/// }
/// ```
///
/// When choosing keys, you have to consider the four following aspects:
/// 1. The key must not be equal to the name of a type.
/// 2. The key must not contain `<` and `>`.
/// 3. The key must conform to the `Hashable` protocol.
/// 4. The key must be unique across all registered types.
///
/// - Important: This property wrapper is not applicable to Optionals. If you are facing such a
///             situation, use `Optject` instead.
@propertyWrapper public struct Inject<V> {
    
    // MARK: - PROPERTIES
    
    /// This property stores the UUID for a specific property wrapper. It is especially used by
    /// `Service` to differentiate requesters and thus be able to manage the objects.
    private let uuid: UUID
    private let key: AnyHashable
    
    public var wrappedValue: V {
        get {
            let value: V? = Injectle.getLocator().getObject(forKey: self.key,
                                                            requester: self.uuid)
            
            guard let value = value else {
                fatalError("Unexpectedly found nil while requesting" +
                           "a service for key '\(key)'")
            }
            
            return value
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
