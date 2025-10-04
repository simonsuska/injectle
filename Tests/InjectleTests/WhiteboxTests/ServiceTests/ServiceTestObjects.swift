// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation
import Mockaffee
import Injectle

class ServiceTestClass {
    private var value: Int
    init(value: Int) { self.value = value }
    func someMethod() -> Int { value }
}

class ScopeMock: Mock, Scope {
    private let object: Any
    
    init(object: Any) {
        self.object = object
    }
    
    @discardableResult
    public func resolve() -> Any {
        calledReturning() ?? self.object
    }
}
