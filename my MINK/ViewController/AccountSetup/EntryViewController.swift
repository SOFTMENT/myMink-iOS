// Copyright © 2023 SOFTMENT. All rights reserved.

import FirebaseAuth
import UIKit

class EntryViewController: UIViewController {
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var createAnAccountBtn: UIButton!

    override func viewDidLoad() {
        self.loginBtn.layer.cornerRadius = 8
        self.createAnAccountBtn.layer.cornerRadius = 8

       
    }

    @IBAction func loginBtnClicked(_: Any) {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }

    @IBAction func createAnAccountBtnClicked(_: Any) {
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }
}
