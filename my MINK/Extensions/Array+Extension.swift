//
//  Array+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation

extension Array where Element: Equatable {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
    
    mutating func remove(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
}
