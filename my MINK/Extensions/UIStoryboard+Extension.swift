//
//  UIStoryboard+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import UIKit


extension UIStoryboard {
    class func load(_ storyboard: StoryBoard, _ identifier: Identifier) -> UIViewController {
        UIStoryboard(name: storyboard.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
