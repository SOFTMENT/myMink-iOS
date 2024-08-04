//
//  FavoritesManager.swift
//  my MINK
//
//  Created by Vijay Rathore on 29/05/24.
//

import Foundation
import Combine

class FavoritesManager : ObservableObject {
    
    static let shared = FavoritesManager()
       
       @Published var favoritePosts: [String: Bool] = [:]
       let favoriteChanged = PassthroughSubject<String, Never>()
       
       private init() { }

    
        func toggleFavorite(for postID : String, isLiked : Bool) {
           
           favoritePosts[postID] = isLiked
           
           favoriteChanged.send(postID)
       }

       func isFavorite(_ postID: String) -> Bool {
           return favoritePosts[postID] ?? false
       }
    
    func setFavorites(with postID : String, isLiked : Bool) {
    
        favoritePosts[postID] = isLiked
    }
    
    
}
