//
//  RoundedUIView.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
@IBDesignable public class RoundedUIView: UIView {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //hard-coded this since it's always round
        layer.cornerRadius = 0.5 * bounds.size.width
        dropShadow()
    }
}
