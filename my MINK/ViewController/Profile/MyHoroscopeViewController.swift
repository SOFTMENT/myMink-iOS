//
//  MyHoroscopeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/02/24.
//

import UIKit
import SDWebImage

class MyHoroscopeViewController: UIViewController {
    
    var myHoroscope: String?
    var result: String?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var shareBtn: UIImageView!
    @IBOutlet weak var mProfile: SDAnimatedImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var horoscopeLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var mView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let myHoroscope = myHoroscope, let result = result else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        setupUI()
        setupGestures()
        
        resultLbl.text = result
        horoscopeLbl.text = myHoroscope.uppercased()
        date.text = convertDateFormaterWithoutDash(Date())
    }
    
    private func setupUI() {
        mView.layer.cornerRadius = 8
        mView.dropShadow()
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        
        mProfile.layer.cornerRadius = mProfile.bounds.height / 2
        
        if let path = UserModel.data?.profilePic, !path.isEmpty {
            mProfile.setImage(imageKey: path, placeholder: "profile-placeholder", shouldShowAnimationPlaceholder: true)
        }
        
        mName.text = UserModel.data?.fullName ?? ""
    }
    
    private func setupGestures() {
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareBtnClicked)))
    }
    
    @objc private func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func shareBtnClicked() {
        if let image = preparePostScreenshot(view: mView) {
            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = view
            present(activityViewController, animated: true, completion: nil)
        }
    }
}
