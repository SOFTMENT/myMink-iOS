//
//  Transactions.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class Transactions: NSObject, Codable {
    
    var transactionId : String?
    var type : String?
    var title : String?
    var desc : String?
    var eventEndDate : Date?
    var amount : Double
    var time : Date?
    
}
