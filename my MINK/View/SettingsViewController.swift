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
