// Copyright © 2023 SOFTMENT. All rights reserved.

// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol.

public final class AmplifyModels: AmplifyModelRegistration {
    public let version: String = "9e10e79809c3d62ccf6a175c297af0c1"

    public func registerModels(registry _: ModelRegistry.Type) {
        ModelRegistry.register(modelType: Todo.self)
    }
}
