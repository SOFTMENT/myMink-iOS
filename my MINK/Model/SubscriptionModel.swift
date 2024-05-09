// Copyright © 2023 SOFTMENT. All rights reserved.

class SubscriptionModel: Decodable {
    var status: Bool?
    var response: Response?
}

class Response: Decodable {
    var planId: String?
    var status: String?
    var createdAt: DateTime?
    var billingPeriodEndDate: DateTime?
    var trialPeriod: Bool?
}

class DateTime: Decodable {
    var date: String?
}
