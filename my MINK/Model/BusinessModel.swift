//
//  BusinessModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit

class BusinessModel : NSObject, Codable {
    
    var businessId : String?
    var uid : String?
    var name : String?
    var website : String?
    var profilePicture : String?
    var aboutBusiness : String?
    var createdAt : Date?
    var coverPicture : String?
    var businessCategory : String?
    var isActive : Bool?
    var shareLink : String?
    var notificationToken : String?
    var deviceToken : String?
    var lastPostDate: Date?
    
}
