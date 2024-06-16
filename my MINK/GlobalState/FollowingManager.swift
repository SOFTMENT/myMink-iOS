//
//  FollowingManager.swift
//  my MINK
//
//  Created by Vijay Rathore on 16/06/24.
//

import Foundation
import Combine

class FollowingManager : ObservableObject {
    
    static let shared = FollowingManager()
       
       
       let followingChanged = PassthroughSubject<String?, Never>()
       
       private init() { }
    
        func following(uid : String?) {
           
           followingChanged.send(uid)
       }
    
}
