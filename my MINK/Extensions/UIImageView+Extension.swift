//
//  UIImageView+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import UIKit
import SDWebImage
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
    
    func makeRounded() {
        // self.layer.borderWidth = 1
        layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
    
    func setImage(
        
        imageKey: String?,
        placeholder: String,
        width: Int = 300,
        height: Int = 300,
        shouldShowAnimationPlaceholder: Bool = false
    ) {
        guard let imageKey = imageKey else {
            return
        }
        let original = "\(Constants.awsImageBaseURL)/fit-in/\(width)x\(height)/public/\(imageKey)"
        
        let actualImageURL = URL(string: original)
   
        let mImage = SDAnimatedImageView()
        let placeholder1 = SDAnimatedImage(named: "imageload.gif")
        mImage.image = placeholder1

        if shouldShowAnimationPlaceholder {
            sd_setImage(with: actualImageURL, placeholderImage: placeholder1) { _, error, _, _ in
                if let error = error {
                       print("Error loading image: \(error.localizedDescription)")
                }
                mImage.stopAnimating()
            }
        } else {
            sd_setImage(with: actualImageURL, placeholderImage: UIImage(named: placeholder))
        }
    }
    
    func setImageOther(
        
        imageURL: String?,
        placeholder: String,
        shouldShowAnimationPlaceholder: Bool = false
    ) {
        
        if  let original = imageURL {
            let actualImageURL = URL(string: original)
       
            let mImage = SDAnimatedImageView()
            let placeholder1 = SDAnimatedImage(named: "imageload.gif")
            mImage.image = placeholder1

            if shouldShowAnimationPlaceholder {
                sd_setImage(with: actualImageURL, placeholderImage: placeholder1) { _, error, _, _ in
                    if let error = error {
                           print("Error loading image: \(error.localizedDescription)")
                    }
                    mImage.stopAnimating()
                }
            } else {
                sd_setImage(with: actualImageURL, placeholderImage: UIImage(named: placeholder))
            }
        }
        
      
    }
}
