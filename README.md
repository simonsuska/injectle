<div align="center">
  <img src="Injectle.svg" alt="Injectle" width="168"><br><br>

  **Injectle** is a service locator for dependency injection in Swift.

  [![GitHub Release](https://img.shields.io/github/v/release/simonsuska/injectle?color=F05138)](https://github.com/simonsuska/injectle/releases)
  [![Static Badge](https://img.shields.io/badge/swift-5.9-important?style=flat&color=F05138)](https://swift.org)
  [![GitHub License](https://img.shields.io/github/license/simonsuska/injectle)](https://github.com/simonsuska/injectle/blob/main/LICENSE)
</div>

---

## 🔎 Table of Contents

- [🎯 About](#about)
- [🚀 Getting Started](#getting_started)
- [💫 Usage](#usage)
- [🚫 Limitations](#limitations)
- [🧱 UML Class Diagram](#uml_cd)
- [⚖️ License](#license)

<div id="about"/>

## 🎯 About

The API of this library is partly inspired by [get_it](https://github.com/fluttercommunity/get_it), 
an awesome service locator for Dart and Flutter projects. Injectle provides some
functionality for projects in Swift, including:

- Registering factory services
- Registering singleton services
- Registering lazy singleton services
- Unregistering services
- Resetting a service locator

Note that this library is not meant to compete with `@EnvironmentObject` when using SwiftUI. It 
provides an alternative to initializer injection for custom types.

This project uses [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
since June 4, 2025.

<div id="getting_started"/>

## 🚀 Getting Started

To get started, add a dependency to your project in Xcode. You may proceed as follows\*:

#### If you want to add a dependency to a Xcode project

1. From the menu bar in Xcode, choose *File* &#8594; *Add Package Dependencies...*
2. A dialog opens where you can add the dependency by pasting the URL of the repository 
   into the search bar in Xcode. \
   If you cloned this repository, you can add a dependency to the repository on your
   machine by choosing *Add Local...*
3. Add the package dependency to the app target

#### If you want to add a dependency to another Swift package

Customize your `Package.swift` file according to the following code.
You may specify a branch instead of a version number.

```swift
let package = Package(
    name: "SomeSwiftPackage",
    dependencies: [
        .package(url: "https://github.com/simonsuska/injectle.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SomeSwiftPackage",
            dependencies: [.product(name: "Injectle", package: "injectle")]),
        // You may also add a dependency to the test target to use the test locator
        .testTarget(
            name: "SomeSwiftPackageTests",
            dependencies: [.product(name: "Injectle", package: "injectle")]),
    ]
)
```

\*Done with Xcode Version 15.0

<div id="usage"/>

## 💫 Usage

### First Taste

```swift
// Register services on app launch
func appDidFinishLaunching() {
    Injectle[.default].registerFactory(Bmw(model: "M5"))
    Injectle[.default].registerFactory(Bmw(model: "M2"), forKey: "bmw-m2")

    Injectle[.default].registerSingleton(DeLorean())
            
    Injectle[.default].registerLazySingleton(RandomCar(), forKey: "unknown")
}

// Access those services with the appropriate property wrappers
class Carpool {
    @Inject var bmwM5: Bmw
    @Inject("bmw-m2") var bmwM2: Bmw

    @Inject var deLorean: DeLorean
    @Inject var sameDeLorean: DeLorean
    
    @Optject("unknown") var unknownCar: (any Car)?
}
```

### In Detail

The Injectle service locator has two different instances, a default locator and a test locator.
If you are confused about this implementation, do not worry, you can use Injectle as a normal
service locator using only the default instance. The test instance merely offers an additional option for registrations that are only available during testing, which can be convenient.

You can access the instances via a subscript

```swift
// Obtaining the default locator
Injectle[.default]

// Obtaining the test locator
Injectle[.test]
```

**Registering factory services**

A factory service returns a new object for every property. When the same property is accessed 
multiple times, the same manufactured object is returned rather than creating a new one. 

In order for an object to be registered as a factory, its class must conform to `NSCopying`.

```swift
class Bmw {
    private var model: String

    init(model: String) {
        self.model = model
    }
}

extension Bmw: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        // Simply pass all parameter values to create a copy
        Bmw(model: self.model)
    }
}
```

To register a factory service, use either the `registerFactory(_:forKey:)` method or the 
`registerFactory(_:forKey:and:)` method. If you want to register different factory services
of the same type, you have to use keys.

```swift
// With implicitly allowed reassignment. 
// Implicit key = Type of object
Injectle[.default].registerFactory(Bmw(model: "M5"))

// With implicitly allowed reassignment. 
// Explicit key = "bmw-m2"
Injectle[.default].registerFactory(Bmw(model: "M2"), forKey: "bmw-m2")
```

The registered services can be accessed via the property wrappers `@Inject` and `@Optject`.
Whereas `@Inject` can only be applied to non-Optionals, `@Optject` can only be applied to Optionals.

```swift
class Carpool {
    // Injected with a newly created object `Bmw(model: "M5")`
    @Inject var bmwM5: Bmw

    // Injected with a newly created object `Bmw(model: "M5")`
    @Inject var anotherBmwM5: Bmw

    // Injected with a newly created object `Bmw(model: "M2")`
    @Inject("bmw-m2") var bmwM2: Bmw

    // Injected with `nil`, since no service has been registered
    // for the key "bmw-m9"
    @Optject("bmw-m9") var bmwM9: Bmw?
}
```

Note that the objects should be passed directly to the appropriate method to avoid the creation of an unnecessary object.

```swift
// Avoid
let bmwM5Factory = Bmw(model: "M5")
Injectle[.default].registerFactory(bmwM5Factory)

// Better
Injectle[.default].registerFactory(Bmw(model: "M5"))
```

**Registering singleton services**

A singleton service returns the same object for every property.

To register a singleton service, use either the `registerSingleton(_:forKey:)` method or the 
`registerSingleton(_:forKey:and:)` method. If you want to register different singleton services
of the same type, you have to use keys.

```swift
// With implicitly allowed reassignment. 
// Implicit key = Type of object
Injectle[.default].registerSingleton(DeLorean())

// With implicitly allowed reassignment. 
// Explicit key = "another-one"
Injectle[.default].registerSingleton(DeLorean(), forKey: "another-one")
```

The registered services can be accessed via the property wrappers `@Inject` and `@Optject`.
Whereas `@Inject` can only be applied to non-Optionals, `@Optject` can only be applied to Optionals.

```swift
class Carpool {
    // Injected with the registered singleton object `DeLorean()`
    @Inject var deLorean: DeLorean

    // Injected with the same registered singleton object 
    // `DeLorean()` as above
    @Inject var sameDeLorean: DeLorean

    // Injected with the registered singleton object 
    // `DeLorean()`, but a different one as above
    @Inject("another-one") var anotherDeLorean: DeLorean

    // Injected with `nil`, since no service has been registered
    // for the key "de-lorean-2024"
    @Optject("de-lorean-2024") var newDeLorean: DeLorean?
}
```

**Registering lazy singleton services**

A lazy singleton service returns the same object for every property. In contrast to a common
singleton service, the object of a lazy singleton service is only created the first time it is accessed.

To register a lazy singleton service, use either the `registerLazySingleton(_:forKey:)` method or the `registerLazySingleton(_:forKey:and:)` method. If you want to register different lazy singleton
services of the same type, you have to use keys.

```swift
// With implicitly allowed reassignment. 
// Implicit key = Type of object
Injectle[.default].registerLazySingleton(DeLorean())

// With implicitly allowed reassignment. 
// Explicit key = "another-one"
Injectle[.default].registerLazySingleton(DeLorean(), forKey: "another-one")
```

The registered services can be accessed via the property wrappers `@Inject` and `@Optject`.
Whereas `@Inject` can only be applied to non-Optionals, `@Optject` can only be applied to Optionals.

```swift
class Carpool {
    // Injected with the registered lazy singleton object `DeLorean()`
    @Inject var deLorean: DeLorean

    // Injected with the same registered lazy singleton 
    // object `DeLorean()` as above
    @Inject var sameDeLorean: DeLorean

    // Injected with the registered lazy singleton object 
    // `DeLorean()`, but a different one as above
    @Inject("another-one") var anotherDeLorean: DeLorean

    // Injected with `nil`, since no service has been registered
    // for the key "de-lorean-2024"
    @Optject("de-lorean-2024") var newDeLorean: DeLorean?
}
```

Note that the objects should be passed directly to the appropriate method. Otherwise it would be 
nothing but a default singleton.

```swift
// Avoid
let deLorean = DeLorean()
Injectle[.default].registerLazySingleton(deLorean)

// Better
Injectle[.default].registerLazySingleton(DeLorean())
```

**Defining custom keys**

You are free to define your own keys as long as they meet the following criteria:
1. The key must not be equal to the name of a type.
2. The key must not contain `<` and `>`.
3. The key must conform to the `Hashable` protocol.
4. The key must be unique across all registered types.

**Unregistering services**

Note that unregistering a service also permanently removes all objects, be they singletons 
or manufactured objects.

```swift
// Unregisters the service of type `DeLorean` that 
// has been registered without a specific key
Injectle[.default].unregisterService(DeLorean.self)

// Unregisters the service that has been registered with
// the specific key "another-one"
Injectle[.default].unregisterService(withKey: "another-one")
```

**Removing single objects and references**

Properties annotated with `@Inject` or `@Optject` are not settable. However, when using 
`@Optject`, it is possible to assign `nil`. Depending on the type of service, this has 
different effects:

- For factory services, the single manufactured object will be removed. The service itself and 
  further manufactured objects remain untouched.
- For (lazy) singleton services, the single reference to the singleton object is removed. The 
  service itself, the singleton object and further references remain untouched.

```swift
// Registering services
Injectle[.default].registerFactory(Bmw(model: "M5"))
Injectle[.default].registerSingleton(DeLorean())

// Accessing those services using `@Optject`
class Carpool {
    @Optject var bmwM5: Bmw?
    @Optject var anotherBmwM5: Bmw?

    @Optject var deLorean: DeLorean?
    @Optject var sameDeLorean: DeLorean?
}

let carpool = Carpool()

// The manufactured object is removed, if it exists.
// However, the factory service itself and the manufactured
// object of `anotherBmwM5` remain the same.
carpool.bmwM5 = nil

// Accessing a property after assigning `nil`
// results in `nil`, rather than creating a new object.
carpool.bmwM5

// The reference to the singleton object is removed.
// However, the singleton object remains the same and
// can still be accessed through `sameDeLorean`.
carpool.deLorean = nil

// Accessing a property after assigning `nil` 
// results in `nil`, rather than the singleton object.
carpool.deLorean
```

**Resetting a service locator**

Note that resetting a service locator permanently unregisters all contained services.

```swift
// Resetting the default locator
Injectle.reset(.default)

// Resetting the test locator
Injectle.reset(.test)

// Resetting all locators
Injectle.resetAll()
// equal to
Injectle.reset(.default, .test)
```

**Testing with Injectle**

If you decide to not use the test locator, you may use an if-statement to register different services for testing and production.

```swift
if testing {
    Injectle[.default].registerSingleton(DeLoreanMock(), forKey: "deLorean")
} else {
    Injectle[.default].registerSingleton(DeLorean(), forKey: "deLorean")
}
```

However, if you decide to use the test locator, you do not have to use an if-statement but merely
the test locator.

```swift
Injectle[.default].registerSingleton(DeLorean(), forKey: "deLorean")
Injectle[.test].registerSingleton(DeLoreanMock(), forKey: "deLorean")
```

To use the services of the test locator in your tests, simply call `testUp()` in the `setUp()` method and `testDown()` in the `tearDown()` method. 

The call of `testUp()` causes `@Inject` and `@Optject` to search for the services in the test locator
whereas `testDown()` restores the default behavior which is using the default locator.

```swift
final class SomeTests: XCTestCase {
    override class func setUp() {
        Injectle.testUp()
    }

    override class func tearDown() {
        Injectle.testDown()
    }
}
```

<div id="limitations"/>

## 🚫 Limitations

The provided functionality still has its limitations. The following use cases are currently not covered and may result in an undefined behavior.

1. Registering value types (`struct`, `enum`)

2. Registering objects with an asynchronous initializer

<div id="uml_cd"/>

## 🧱 UML Class Diagram

![UML Class Diagram](Injectle_UML_CD.svg)

<div id="license"/>

## ⚖️ License

Injectle is released under the GNU GPL-3.0 license. See [LICENSE](LICENSE) for details.
