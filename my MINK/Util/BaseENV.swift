 // Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - BaseENV

class BaseENV {
    // MARK: Lifecycle

    init(resourcesName: String) {
        guard let filePath = Bundle.main.path(forResource: resourcesName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath)
        else {
            fatalError("Could not find \(resourcesName) ")
        }
        self.dict = plist
    }

    // MARK: Internal

    let dict: NSDictionary
}

// MARK: - APIKeyable

protocol APIKeyable {
    var GOOGLE_PLACES_API_KEY: String { get }
    var CLOUDINARY_NAME: String { get }
    var CLOUDINARY_API_KEY: String { get }
    var CLOUDINARY_API_SECRET: String { get }
    var ClientTokenOrTokenizationKey: String { get }
    var REMOVE_BG_API: String { get }
}

// MARK: - DebugENV

class DebugENV: BaseENV, APIKeyable {
    // MARK: Lifecycle

    init() {
        super.init(resourcesName: "DEBUG-Keys")
    }

    // MARK: Internal

    var CLOUDINARY_NAME: String {
        dict.object(forKey: "CLOUDINARY_NAME") as? String ?? ""
    }

    var CLOUDINARY_API_KEY: String {
        dict.object(forKey: "CLOUDINARY_API_KEY") as? String ?? ""
    }

    var CLOUDINARY_API_SECRET: String {
        dict.object(forKey: "CLOUDINARY_API_SECRET") as? String ?? ""
    }

    var GOOGLE_PLACES_API_KEY: String {
        dict.object(forKey: "GOOGLE_PLACES_API_KEY") as? String ?? ""
    }

    var ClientTokenOrTokenizationKey: String {
        dict.object(forKey: "ClientTokenOrTokenizationKey") as? String ?? ""
    }

    var REMOVE_BG_API: String {
        dict.object(forKey: "REMOVE_BG_API") as? String ?? ""
    }
}

// MARK: - ProdENV

class ProdENV: BaseENV, APIKeyable {
    // MARK: Lifecycle

    init() {
        super.init(resourcesName: "PROD-Keys")
    }

    // MARK: Internal

    var CLOUDINARY_NAME: String {
        dict.object(forKey: "CLOUDINARY_NAME") as? String ?? ""
    }

    var CLOUDINARY_API_KEY: String {
        dict.object(forKey: "CLOUDINARY_API_KEY") as? String ?? ""
    }

    var CLOUDINARY_API_SECRET: String {
        dict.object(forKey: "CLOUDINARY_API_SECRET") as? String ?? ""
    }

    var GOOGLE_PLACES_API_KEY: String {
        dict.object(forKey: "GOOGLE_PLACES_API_KEY") as? String ?? ""
    }

    var ClientTokenOrTokenizationKey: String {
        dict.object(forKey: "ClientTokenOrTokenizationKey") as? String ?? ""
    }

    var REMOVE_BG_API: String {
        dict.object(forKey: "REMOVE_BG_API") as? String ?? ""
    }
}
