import Foundation
import Injectle

protocol OptjectProtocol: NSCopying {
    func someMethod() -> Int
}

class OptjectClass: OptjectProtocol {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return OptjectClass(value: self.value)
    }
}

class AnotherOptjectClass: OptjectProtocol {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return AnotherOptjectClass(value: self.value)
    }
}

class OptjectTestClass {
    @Optject var concrProperty: OptjectClass?
    @Optject var concrPropertyToo: OptjectClass?
    
    @Optject var anotherConcrProperty: AnotherOptjectClass?
    @Optject(OK.atcKey) var yetAnotherConcrProperty: AnotherOptjectClass?
    
    @Optject(OK.pKey) var protProperty: (any OptjectProtocol)?
    @Optject(OK.pKey) var anotherProtProperty: (any OptjectProtocol)?
    
    @Optject(OK.eKey) var emptyProperty: (any OptjectProtocol)?
    
    @Optject var removeProperty: RemoveOptjectClass?
    @Optject var removePropertyToo: RemoveOptjectClass?
    @Optject var removePropertyAgain: RemoveOptjectClass?
}

class RemoveOptjectClass: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return RemoveOptjectClass()
    }
}

enum OK {
    case atcKey
    case pKey
    case eKey
}
