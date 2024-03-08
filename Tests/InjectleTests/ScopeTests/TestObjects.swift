import Foundation
import Injectle

class ScopeTestClass {
    private var value: Int
    init(value: Int) { self.value = value }
    func someMethod() -> Int { value }
}
