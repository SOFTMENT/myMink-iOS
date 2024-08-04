// Copyright © 2023 SOFTMENT. All rights reserved.

import FirebaseAuth
import UIKit

class EntryViewController: UIViewController {
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var createAnAccountBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        loginBtn.layer.cornerRadius = 8
        createAnAccountBtn.layer.cornerRadius = 8
    }

    @IBAction func loginBtnClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }

    @IBAction func createAnAccountBtnClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }
}
