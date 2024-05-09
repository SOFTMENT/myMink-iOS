//
//  SavesManager.swift
//  my MINK
//
//  Created by Vijay Rathore on 30/05/24.
//

import Foundation
import Combine

class SavedManager: ObservableObject {
    
    static let shared = SavedManager()
       
       @Published var savedPosts: [String: Bool] = [:]
       let saveChanged = PassthroughSubject<String, Never>()
       
       private init() { }
    
        func toggleSave(for postID : String, isSave : Bool) {
           
           savedPosts[postID] = isSave
           saveChanged.send(postID)
       }

       func isSave(_ postID: String) -> Bool {
           return savedPosts[postID] ?? false
       }
    
    func setSave(with postID : String, isSave : Bool) {
        savedPosts[postID] = isSave
    }
    
}
