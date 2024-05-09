// Copyright © 2023 SOFTMENT. All rights reserved.

import Foundation
import UIKit

private var xoAssociationKey: UInt8 = 0

extension UIImageView {
    @nonobjc static var imageCache = NSCache<NSString, AnyObject>()
    var imageURL: String? {
        get {
            objc_getAssociatedObject(self, &xoAssociationKey) as? String
        }
        set(newValue) {
            guard let urlString = newValue else {
                objc_setAssociatedObject(
                    self,
                    &xoAssociationKey,
                    newValue,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
                )
                image = nil
                return
            }
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if let image = UIImageView.imageCache
                .object(forKey: "\((urlString as NSString).hash)" as NSString) as? UIImage
            {
                self.image = image
                return
            }
            DispatchQueue.global().async { [weak self] in
                guard let url = URL(string: urlString as String) else {
                    return
                }
                guard let data = try? Data(contentsOf: url) else {
                    return
                }
                let image = UIImage(data: data)
                guard let fetchedImage = image else {
                    return
                }
                DispatchQueue.main.async {
                    UIImageView.imageCache.setObject(fetchedImage, forKey: "\(urlString.hash)" as NSString)
                    guard let pastImageURL = self?.imageURL,
                          url.absoluteString == pastImageURL
                    else {
                        self?.image = nil
                        return
                    }
                    let animation = CATransition()
                    animation.type = CATransitionType.fade
                    animation.duration = 0.3
                    self?.layer.add(animation, forKey: "transition")
                    self?.image = fetchedImage
                }
            }
        }
    }
}
