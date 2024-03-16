import Foundation

class InjectleTestClass: NSCopying {
    private var value: Int
    
    init(value: Int) {
        print("INIT INJECTLETESTCLASS")
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return InjectleTestClass(value: self.value)
    }
}

class AnotherInjectleTestClass: NSCopying {
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func someMethod() -> Int {
        value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return AnotherInjectleTestClass(value: self.value)
    }
}

class UnregisterInjectleTestClass {}
