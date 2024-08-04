//
//  ToDoOnBoardViewController.swift
//  |
//
//  Created by Vijay Rathore on 05/02/24.
//

import UIKit

class ToDoOnBoardViewController: UIViewController {
    
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mDesign: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        getStartedBtn.layer.cornerRadius = 8
        
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        mDesign.clipsToBounds = true
        mDesign.layer.cornerRadius = 20
        mDesign.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    @IBAction func getStartedClicked(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "todo2ndTime")
        performSegue(withIdentifier: "todoDetailsSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todoDetailsSeg" {
            if let VC = segue.destination as? ToDoDashboardViewController {
                VC.fromOnBoard = true
            }
        }
    }
}
