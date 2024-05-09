//
//  RevenuePopupViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class RevenuePopupViewController: UIViewController {
    
    @IBOutlet weak var totalPrice: UILabel!
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var serviceFee: UILabel!
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var ticketRevenue: UILabel!
    @IBOutlet weak var total: UILabel!
    
    var mPrice : Int?
    override func viewDidLoad() {
        
        guard let mPrice = mPrice else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        
        totalPrice.text = "$\(String(format: "%.2f", Double(mPrice)))"
        let mServiceFee = Double(mPrice) / Double(10)
        
        serviceFee.text = "$\(String(format: "%.2f", Double(mServiceFee)))"
        
        total.text = "$\(String(format: "%.2f", (Double(mPrice) + mServiceFee)))"
         
        ticketRevenue.text = "$\(String(format: "%.2f", Double(mPrice)))"
        
        mView.layer.cornerRadius = 4
        mView.dropShadow()
        
        doneBtn.isUserInteractionEnabled = true
        doneBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneBtnClicked)))
        
    }
    
    @objc func doneBtnClicked(){
        self.dismiss(animated: true, completion: nil)
    }
}
