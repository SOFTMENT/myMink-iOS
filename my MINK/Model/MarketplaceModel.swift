//
//  MarketplaceModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 09/04/24.
//

import UIKit

class MarketplaceModel : NSObject, Codable {
    
    var id : String?
    var uid : String?
    var title : String?
    var cost : String?
    var about : String?
    var categoryName : String?

    var productUrl : String?
    var dateCreated : Date?
    var isActive : Bool?
    var countryCode : String?
    var currency : String?
    var productImages: [String]?
    
}
