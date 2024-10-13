//
//  CouponModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 30/04/24.
//

import UIKit

class CouponModel: NSObject, Codable {
    var couponCode: String?
    var id: String?
   
    
    init(data: [String: Any]) {
        self.couponCode = data["couponCode"] as? String
        self.id = data["id"] as? String
    }
}
