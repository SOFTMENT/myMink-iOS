//
//  MyHoroscopeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/02/24.
//

import UIKit
import SDWebImage

class MyHoroscopeViewController : UIViewController {
    
    var myHoroscope : String?
    var result : String?
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var shareBtn: UIImageView!

    @IBOutlet weak var mProfile: SDAnimatedImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var horoscopeLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var mView: UIView!
    override func viewDidLoad() {
        
        guard let myHoroscope = myHoroscope, let result = result else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        resultLbl.text = result
        
        mView.layer.cornerRadius = 8
        mView.dropShadow()
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        mProfile.layer.cornerRadius = mProfile.bounds.height / 2
        
        if let path = UserModel.data!.profilePic, !path.isEmpty {
            mProfile.setImage(imageKey: path, placeholder: "profile-placeholder",shouldShowAnimationPlaceholder: true)
        }
        mName.text = UserModel.data!.fullName ?? ""
        
        horoscopeLbl.text = myHoroscope.uppercased()
        
        date.text = convertDateFormaterWithoutDash(Date())
        
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareBtnClicked)))
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func shareBtnClicked(){
        if let image = preparePostScreenshot(view: mView) {
            var imagesToShare = [AnyObject]()
            imagesToShare.append(image)

            let activityViewController = UIActivityViewController(
                activityItems: imagesToShare,
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
}
