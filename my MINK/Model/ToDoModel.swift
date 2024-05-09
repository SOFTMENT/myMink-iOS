//
//  ToDoModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class ToDoModel : NSObject,Codable {
    
    var id : String?
    var title : String?
    var date : Date?
    var isFinished : Bool?
    var uid : String?
    
}
