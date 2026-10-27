import Foundation

/// What the session builder needs to know about one card: no folders, no persistence.
public struct SessionCard: Sendable, Equatable {
    public var id: UUID
    public var createdAt: Date
    /// Forward direction.
    public var state: SchedulingState

    public init(id: UUID, createdAt: Date, state: SchedulingState = SchedulingState()) {
        self.id = id
        self.createdAt = createdAt
        self.state = state
    }

    /// Never reviewed.
    public var isNew: Bool {
        state.dueDate == nil
    }

    public func isDue(at now: Date) -> Bool {
        state.dueDate.map { $0 <= now } ?? false
    }
}
