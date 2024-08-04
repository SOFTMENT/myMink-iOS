//
//  UIImage+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import UIKit

extension UIImage {
    func addToCenter(of superView: UIView, width: CGFloat = 150, height: CGFloat = 60) {
        let overlayImageView = UIImageView(image: self)
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)

        let centerXConst = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: superView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        let width = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: width
        )
        let height = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        let centerYConst = NSLayoutConstraint(
            item: overlayImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: superView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )

        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}
