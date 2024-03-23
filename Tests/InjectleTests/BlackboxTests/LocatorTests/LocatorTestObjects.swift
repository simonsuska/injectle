import Foundation
import Injectle

class LocatorClass {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
}

class LocatorTestClass {
    @Inject var concrInjectProperty: LocatorClass
    @Inject(LK.liKey) var anotherConcrInjectProperty: LocatorClass
    
    @Optject var concrOptjectProperty: LocatorClass?
    @Optject(LK.loKey) var anotherConcrOptjectProperty: LocatorClass?
}

enum LK {
    case liKey
    case loKey
}
