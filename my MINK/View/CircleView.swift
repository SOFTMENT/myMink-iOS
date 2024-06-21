//
//  CircleView.swift
//  my MINK
//
//  Created by Vijay Rathore on 21/06/24.
//

import UIKit

@IBDesignable class CircleView : UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2

    }
}
