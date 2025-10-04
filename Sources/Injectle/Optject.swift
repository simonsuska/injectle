// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation

/// This type grants access to the registered services of the `Injectle` class.
///
/// Be aware that properties which are annotated with `@Optject` can only be assigned `nil`.
///
/// **Access to services**
///
/// A registered service can be accessed by annotating a property with `@Optject`.
///
/// ```swift
/// class SomeClass {
///     // This property will be injected with an object
///     // of the concrete type `SomeConcreteType`.
///     @Optject var someProperty: SomeConcreteType
/// }
/// ```
///
/// If no service is registered for the specified type or key, the property is assigned `nil`.
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
///     @Optject var someProperty: SomeConcreteType?
///
///     // This property will be injected with an object
///     // of the concrete type `SomeConcreteType` of the
///     // service which has the key "some-key".
///     @Optject("some-key") var anotherProperty: SomeConcreteType?
///
///     // This property will be injected with an object
///     // that conforms to `SomeProtocol` of the
///     // service which has the key "another-key".
///     @Optject("another-key") var yetAnotherProperty: (any SomeProtocol)?
/// }
/// ```
///
/// When choosing keys, you have to consider the four following aspects:
/// 1. The key must not be equal to the name of a type.
/// 2. The key must not contain `<` and `>`.
/// 3. The key must conform to the `Hashable` protocol.
/// 4. The key must be unique across all registered types.
///
/// **Assignment of `nil`**
///
/// In case of a singleton service or lazy singleton service, the assignment of `nil` removes the reference
/// of that property to the singleton object. Accessing such a property again returns `nil` rather than the object.
///
/// ```swift
/// class SomeClass {
///     @Optject var someProperty: SomeSingletonClass?
///     @Optject var anotherProperty: SomeSingletonClass?
/// }
///
/// let someClass = SomeClass()
///
/// // Reference to the singleton object is removed.
/// someClass.someProperty1 = nil
///
/// // Accessing the same property again returns `nil`
/// // rather than the singleton object.
/// someClass.someProperty
///
/// // Other properties can be accessed
/// // normally and are not affected.
/// someClass.anotherProperty
/// ```
///
/// In case of a factory service, the assignment of `nil` removes the manufactured object. Accessing such a
/// property again returns `nil` rather than creating a new object.
///
/// ```swift
/// class SomeClass {
///     @Optject var someProperty: SomeFactoryClass?
///     @Optject var anotherProperty: SomeFactoryClass?
/// }
///
/// let someClass = SomeClass()
///
/// // Concrete manufactured object is 
/// // removed, if it exists.
/// someClass.someProperty1 = nil
///
/// // Accessing the same property again
/// // returns `nil` rather than a new object.
/// someClass.someProperty
///
/// // Other properties can be accessed 
/// // normally and are not affected.
/// someClass.anotherProperty
/// ```
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
            Injectle.getLocator().removeObject(inServiceWithKey: self.key, 
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
