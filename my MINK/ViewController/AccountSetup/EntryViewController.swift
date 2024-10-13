// Copyright © 2023 SOFTMENT. All rights reserved.

import FirebaseAuth
import UIKit

class EntryViewController: UIViewController {
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var createAnAccountBtn: UIButton!

    @IBOutlet weak var eulaCheckbox: UIButton!
    
    @IBOutlet weak var eulaLbl: UILabel!
    @IBOutlet weak var policyLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        eulaLbl.isUserInteractionEnabled = true
        eulaLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eulaClicked)))
        
        policyLbl.isUserInteractionEnabled = true
        policyLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policyClicked)))
    }

    private func setupUI() {
        loginBtn.layer.cornerRadius = 8
        createAnAccountBtn.layer.cornerRadius = 8
    }

    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if eulaCheckbox.isSelected{
            performSegue(withIdentifier: "signInSeg", sender: nil)
        }
        else {
            self.showSnack(messages: "Please agree to the terms and conditions")
        }
      
    }

    @IBAction func createAnAccountBtnClicked(_ sender: UIButton) {
        if eulaCheckbox.isSelected{
            performSegue(withIdentifier: "signUpSeg", sender: nil)
        }
        else {
            self.showSnack(messages: "Please agree to the terms and conditions")
        }
      
    }
    
    @IBAction func eulaCheckboxClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @objc func eulaClicked() {
           
        openURL("https://mymink.com.au/eula/")
    }
    
    @objc func policyClicked() {
        openURL("https://mymink.com.au/terms-of-use/")
    }
    
    private func openURL(_ urlString: String) {
        dismiss(animated: true)
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Use the updated open method with options and completion handler
        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
            if success {
                print("URL was opened successfully.")
            } else {
                print("Failed to open the URL.")
            }
        })
    }

}
