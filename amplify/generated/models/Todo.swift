// Copyright © 2023 SOFTMENT. All rights reserved.

// swiftlint:disable all
import Amplify
import Foundation

public struct Todo: Model {
    // MARK: Lifecycle

    public init(
        id: String = UUID().uuidString,
        name: String,
        priority: Priority? = nil,
        description: String? = nil
    ) {
        self.init(
            id: id,
            name: name,
            priority: priority,
            description: description,
            createdAt: nil,
            updatedAt: nil
        )
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        priority: Priority? = nil,
        description: String? = nil,
        createdAt: Temporal.DateTime? = nil,
        updatedAt: Temporal.DateTime? = nil
    ) {
        self.id = id
        self.name = name
        self.priority = priority
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: Public

    public let id: String
    public var name: String
    public var priority: Priority?
    public var description: String?
    public var createdAt: Temporal.DateTime?
    public var updatedAt: Temporal.DateTime?
}
