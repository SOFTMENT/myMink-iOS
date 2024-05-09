//
//  TicketModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/05/24.
//
import UIKit

class TicketModel : NSObject, Codable {

    var quantity : Int?
    var userName : String?
    var eventName : String?
    var ticketName : String?
    var eventStartDate : Date?
    var eventEndDate : Date?
    var addressName : String?
    var eventId : String?
    var orderNumber : String?
    var eventSummary : String?
    var organizerName : String?
    var userId : String?
    var ticketId : String?
    var ticketBookDate : Date?
    var eventImage : String?
    var organizerUid : String?
    var userEmail : String?
    var isCheckedIn : Bool?
    var checkedInTime : Date?
    var ticketPrice : Int?
    var isFree : Bool?
    var latitude : Double?
    var longitude : Double?
   
   
}
