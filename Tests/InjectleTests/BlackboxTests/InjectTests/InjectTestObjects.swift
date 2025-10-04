// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation
import Injectle

protocol InjectProtocol: NSCopying {
    func someMethod() -> Int
}

class InjectClass: InjectProtocol {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return InjectClass(value: self.value)
    }
}

class AnotherInjectClass: InjectProtocol {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return AnotherInjectClass(value: self.value)
    }
}

class InjectTestClass {
    @Inject var concrProperty: InjectClass
    @Inject var concrPropertyToo: InjectClass
    
    @Inject var anotherConcrProperty: AnotherInjectClass
    @Inject(IK.atcKey) var yetAnotherConcrProperty: AnotherInjectClass
    
    @Inject(IK.pKey) var protProperty: any InjectProtocol
    @Inject(IK.pKey) var anotherProtProperty: any InjectProtocol
}

enum IK {
    case atcKey
    case pKey
}
