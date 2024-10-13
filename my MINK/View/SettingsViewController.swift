// Copyright © 2023 SOFTMENT. All rights reserved.

//
//  SettingsViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 01/07/23.
//
import UIKit
import SDWebImage

class SettingsViewController: UIViewController {
    @IBOutlet var slide: UIView!

    @IBOutlet var editProfile: UIView!
    @IBOutlet weak var profilePic: SDAnimatedImageView!
    
    @IBOutlet var name: UILabel!

    @IBOutlet var email: UILabel!

    @IBOutlet weak var savedView: UIView!
    
    @IBOutlet var shareApp: UIView!

    @IBOutlet var rateApp: UIView!

    @IBOutlet var legalAgreements: UIView!

    @IBOutlet var accountPrivacy: UIView!

    @IBOutlet var logoutBtn: UIView!

    @IBOutlet var contactUs: UIView!

    @IBOutlet var membershipView: UIView!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet weak var languageView: UIStackView!
    @IBOutlet weak var languageLbl: UILabel!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
 

    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)

        self.profilePic.layer.cornerRadius = 8

        self.slide.roundCorners(corners: .allCorners, radius: 10)
        self.logoutBtn.layer.cornerRadius = 8
        self.logoutBtn.layer.borderWidth = 1.2
        self.logoutBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        languageView.isUserInteractionEnabled = true
        languageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(languageClicked)))
        
        // Get the current language from UserDefaults
        if let preferredLanguage = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String {
          
            
            // Extract the language code (e.g., "en", "fr", "es")
            let languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
          
            self.updateLanguageTitle(code: languageCode)
          
        }
    }
    
    func updateLanguageTitle(code: String) {
      
        switch code {
        case "en":
            self.languageLbl.text = "English"
        case "it":
            self.languageLbl.text = "Italiano"
        case "el":
            self.languageLbl.text = "Ελληνικά"
        case "th":
            self.languageLbl.text = "ภาษาไทย"
        case "zh":
            self.languageLbl.text = "中文 (简体)"
        case "nl":
            self.languageLbl.text = "Dutch"
        case "da":
            self.languageLbl.text = "Dansk"
        case "tly":
            self.languageLbl.text = "Tagalog"
        case "fr":
            self.languageLbl.text = "Français"
        case "del":
            self.languageLbl.text = "Deutsch"
        case "id":
            self.languageLbl.text = "Bahasa Indonesia"
        case "ja":
            self.languageLbl.text = "日本語"
        case "ru":
            self.languageLbl.text = "Русский"
        case "es":
            self.languageLbl.text = "Español"
        case "sv":
            self.languageLbl.text = "Svenska"
        case "vi":
            self.languageLbl.text = "Tiếng Việt"
        case "tr":
            self.languageLbl.text = "Türkçe"
        case "pl":
            self.languageLbl.text = "Polski"
        case "nb":
            self.languageLbl.text = "Norsk"
        case "ms":
            self.languageLbl.text = "Bahasa Melayu"
        default:
            self.languageLbl.text = "English" // Default language title
        }
    }

    
    @objc func languageClicked(){
        let alert  = UIAlertController(title: nil, message: "Select Language", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { action in
            self.changeLanguage(code: "en")
           
        }))
        alert.addAction(UIAlertAction(title: "Italiano", style: .default, handler: { action in
            
            self.changeLanguage(code: "it")
          
        }))
        alert.addAction(UIAlertAction(title: "Ελληνικά", style: .default, handler: { action in
            
            self.changeLanguage(code: "el")
          
        }))
        
        alert.addAction(UIAlertAction(title: "ภาษาไทย", style: .default, handler: { action in
            
            self.changeLanguage(code: "th")
          
        }))
        
        alert.addAction(UIAlertAction(title: "中文 (简体)", style: .default, handler: { action in
            
            self.changeLanguage(code: "zh-Hans")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Dutch", style: .default, handler: { action in
            
            self.changeLanguage(code: "nl")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Dansk", style: .default, handler: { action in
            
            self.changeLanguage(code: "da")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Tagalog", style: .default, handler: { action in
            
            self.changeLanguage(code: "tly")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Français", style: .default, handler: { action in
            
            self.changeLanguage(code: "fr")
          
        }))
        
        
        alert.addAction(UIAlertAction(title: "Deutsch", style: .default, handler: { action in
            
            self.changeLanguage(code: "del")
          
        }))
        
    
        alert.addAction(UIAlertAction(title: "Bahasa Indonesia", style: .default, handler: { action in
            
            self.changeLanguage(code: "id")
          
        }))
        
        alert.addAction(UIAlertAction(title: "日本語", style: .default, handler: { action in
            
            self.changeLanguage(code: "ja")
          
        }))
        alert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { action in
            
            self.changeLanguage(code: "ru")
          
        }))
        alert.addAction(UIAlertAction(title: "Español", style: .default, handler: { action in
            
            self.changeLanguage(code: "es")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Svenska", style: .default, handler: { action in
            
            self.changeLanguage(code: "sv")
          
        }))
        alert.addAction(UIAlertAction(title: "Tiếng Việt", style: .default, handler: { action in
            
            self.changeLanguage(code: "vi")
          
        }))
        alert.addAction(UIAlertAction(title: "Türkçe", style: .default, handler: { action in
            
            self.changeLanguage(code: "tr")
          
        }))
        alert.addAction(UIAlertAction(title: "Polski", style: .default, handler: { action in
            
            self.changeLanguage(code: "pl")
          
        }))
        alert.addAction(UIAlertAction(title: "‎Norsk‎", style: .default, handler: { action in
            
            self.changeLanguage(code: "nb")
          
        }))
        alert.addAction(UIAlertAction(title: "Bahasa Melayu", style: .default, handler: { action in
            
            self.changeLanguage(code: "ms")
          
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
            
            //Cancel
          
        }))
      
        
        
        
        present(alert, animated: true)
    }

    func changeLanguage(code : String){
        self.updateLanguageTitle(code: code)
        if code == "en" {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()

        }
        else {
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        
//        Constants.selectedTabBarPosition = 6
//        self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
       
        let alertController = UIAlertController(
            title: "Restart Required".localized(),
            message: "The app needs to restart to apply the language change. Please close and reopen the app to see the changes.".localized(),
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Restart".localized(), style: .default) { _ in
            exit(0)
        }
        
        let okCancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)

        alertController.addAction(okAction)
        alertController.addAction(okCancel)

        present(alertController, animated: true)

    }
    
    override func viewDidLayoutSubviews() {
        if !self.hasSetPointOrigin {
            self.hasSetPointOrigin = true
            self.pointOrigin = view.frame.origin
        }
    }

    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else {
            return
        }

        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)

        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
