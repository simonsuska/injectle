// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import Foundation
import Injectle

class ScopeTestClass: NSCopying {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ScopeTestClass(value: self.value)
    }
}
