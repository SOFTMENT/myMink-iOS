// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import Combine


class UserModel: NSObject, Codable{
    // MARK: Internal

    static var data: UserModel? {
        set(userData) {
            self.userData = userData
        }
        get {
            userData
        }
    }

    var profilePic: String?
    var fullName: String?
    var email: String?
    var uid: String?
    var registredAt: Date?
    var phoneNumber: String?
    var regiType: String?
    var website: String?
    var location: String?
    var gender: String?
    var biography: String?
    var username: String?
    var notificationToken: String?
    var deviceToken: String?
    var encryptKey: String?
    var encryptPassword: String?
    var autoGraphImage: String?
    var isAccountPrivate: Bool?
    var profileURL: String?
    var is2FAActive: Bool?
    var phoneNumber2FA: String?
    var braintreeCustomerId : String?
    var isBlocked : Bool?
    var livestreamingURL : String?
    var isAccountDeactivate : Bool?
    var haveBlueTick : Bool?
    var haveBlackTick : Bool?
    var activeEntitlement : String?
    var entitlementStatus : String?
    var isAccountActive : Bool?
    var daysLeft : Int?
    
    static func clearUserData() {
       userData = nil
    }

    // MARK: Private

    private static var userData: UserModel?
}
