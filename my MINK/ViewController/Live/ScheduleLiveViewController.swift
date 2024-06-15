//
//  ScheduleLiveViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 31/05/24.
//

import UIKit

class ScheduleLiveViewController : UIViewController {
    
    @IBOutlet var backView: UIView!
    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var mView: UIView!
    
    @IBOutlet weak var liveUrl: UILabel!
    
   
    @IBOutlet weak var copyBtn: UIImageView!
    
    override func viewDidLoad() {
        guard let userModel = UserModel.data else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return 
        }
        
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        
        
        self.liveUrl.text = "\(Constants.MY_MINK_APP_DOMAIN)livestram/\(userModel.username ?? "")"
        
        if let livestreamingURL = userModel.livestreamingURL, !livestreamingURL.isEmpty {
            self.liveUrl.text = livestreamingURL
            
        }
        else {
            createDeepLinkForLivestream(userModel: userModel) { url, error in
                if let url = url, !url.isEmpty {
                    UserModel.data?.livestreamingURL = url
                    self.liveUrl.text = url
                    FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid).setData(["livestreamingURL" : url], merge: true)
                }
            }
        }
        
        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))
        
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))
        
       
        
        
        
        copyBtn.isUserInteractionEnabled = true
        copyBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
        
        
    }
   
    @objc func backViewClicked() {
        dismiss(animated: true)
    }
  
    @objc func copyBtnClicked(){
        let url = liveUrl.text ?? ""

        if UIPasteboard.general.string == url {
            return
        }
        UIPasteboard.general.string =  url
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        showSnack(messages: "Copied.")
    }
    
    
    
}
