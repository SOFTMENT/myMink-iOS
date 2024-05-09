//
//  CommentManager.swift
//  my MINK
//
//  Created by Vijay Rathore on 31/05/24.
//
import Foundation
import Combine

class CommentManager: ObservableObject {
    
    static let shared = CommentManager()
       
       
       let commentChanged = PassthroughSubject<String, Never>()
       
       private init() { }
    
        func reloadComment(for postID : String) {
           
           commentChanged.send(postID)
       }
    
}
