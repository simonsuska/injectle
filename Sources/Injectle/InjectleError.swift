import Foundation

/// This type defines all possible errors.
public enum InjectleError: Error {
    /// This type of error is thrown by `forbidReassignment(in:forKey:)` of the `Injectle` class
    /// when registering a service with forbidden reassignment but a service is already registered for the
    /// specified type or key.
    case forbiddenReassignment
}
