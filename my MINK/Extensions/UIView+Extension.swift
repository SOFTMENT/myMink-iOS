//
//  UIView+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import UIKit

extension UIView {
    func addBorder() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
    }

    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.currentUIWindow() {
                return window.safeAreaInsets.bottom
            }
        } else {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
        return 34
    }

    func smoothShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(
            x: 0,
            y: bounds.maxY - layer.shadowRadius,
            width: bounds.width,
            height: layer.shadowRadius
        )).cgPath
    }

    func installBlurEffect(isTop: Bool) {
        backgroundColor = UIColor.clear
        var blurFrame = bounds

        if isTop {
            var statusBarHeight: CGFloat = 0.0
            if #available(iOS 13.0, *) {
                if let window = UIApplication.shared.currentUIWindow() {
                    statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                }
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }

            blurFrame.size.height += statusBarHeight
            blurFrame.origin.y -= statusBarHeight
        } else {
            if let window = UIApplication.shared.currentUIWindow() {
                let bottomPadding = window.safeAreaInsets.bottom
                blurFrame.size.height += bottomPadding
            }

            //  blurFrame.origin.y += bottomPadding
        }
        let blur = UIBlurEffect(style: .light)
        let visualeffect = UIVisualEffectView(effect: blur)
        visualeffect.backgroundColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 0.7)
        visualeffect.frame = blurFrame
        addSubview(visualeffect)
    }

    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1.5
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath

        layer.mask = mask
    }
}
