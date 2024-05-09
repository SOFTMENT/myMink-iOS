//
//  CountryModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 07/05/24.
//
import UIKit

class CountryModel : Codable {
    let name, dialCode,currency,code: String

    enum CodingKeys: String, CodingKey {
        case name
        case dialCode = "dial_code"
        case code
        case currency
    }

    init(name: String, dialCode: String, code: String, currency : String) {
        self.name = name
        self.dialCode = dialCode
        self.code = code
        self.currency = currency
    }
}
