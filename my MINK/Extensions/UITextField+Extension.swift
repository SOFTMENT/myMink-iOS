//
//  UITextField+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import UIKit

extension UITextField {
    func setLeftView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 22, height: 22)) // set your Own size
        iconView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
        tintColor = .lightGray
    }

    func setRightView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 22, height: 22)) // set your Own size
        iconView.image = image
        iconView.isUserInteractionEnabled = false
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        iconContainerView.isUserInteractionEnabled = false
        rightView = iconContainerView
        rightView?.isUserInteractionEnabled = false
        rightViewMode = .always
        tintColor = .lightGray
    }

    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))

        rightView = paddingView
        rightViewMode = .always
    }

    func changePlaceholderColour() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 225 / 255,
                green: 225 / 255,
                blue: 225 / 255,
                alpha: 1
            )]
        )
    }

    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        let padding = 8
        let size = 20

        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)

        leftView = outerView
        leftViewMode = .always
    }

    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        let padding = 8
        let size = 12

        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)

        rightView = outerView
        rightViewMode = .always
    }
}
