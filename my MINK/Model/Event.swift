//
//  Event.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/05/24.
//


import UIKit

class Event: NSObject, Codable {
    
    var eventId : String?
    var eventCreateDate : Date?
    var eventOrganizerUid : String?
    var eventTitle : String?
    var tags : String?
    var latitude : Double?
    var longitude : Double?
    var addressName : String?
    var address : String?
   
    var city : String?
    var state : String?
    var postal : String?
    var country : String?
    var eventStartDate : Date?
    var eventEndDate : Date?
    var eventTicketSold : Int?
    var countryCode : String?
    
    var isActive : Bool?
    var eventImage1 : String?
    var eventImage2 : String?
    var eventImage3 : String?
    var eventImage4 : String?
    var eventDescription : String?
    
    var isFree : Bool?
    var ticketName : String?
    var ticketQuantity : Int?
    var ticketPrice : Int?
    var eventURL : String?

    private static var eventDatas : [Event] = []
   
   
    static var datas  : [Event] {
        set(event) {
            self.eventDatas = event
        }
        get {
            return eventDatas
        }
    }


    override init() {
        
    }
    
}
