//
//  DailyHoroscopeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/02/24.
//

import UIKit

class DailyHoroscopeViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var ariesView: UIView!
    @IBOutlet weak var taurusView: UIView!
    @IBOutlet weak var geminiView: UIView!
    
    @IBOutlet weak var cancerView: UIView!
    
    @IBOutlet weak var leoView: UIView!
    
    @IBOutlet weak var virgoView: UIView!
    
    @IBOutlet weak var libraView: UIView!
    
    @IBOutlet weak var scorpioView: UIView!
    
    @IBOutlet weak var sagitariusView: UIView!
    
    @IBOutlet weak var capricornusView: UIView!
    @IBOutlet weak var aquariusView: UIView!
    @IBOutlet weak var piscesView: UIView!
    var token : String?
    var horoscopeModel : HoroscopeModel?
    
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        ariesView.isUserInteractionEnabled = true
        ariesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ariesClicked)))
        
        taurusView.isUserInteractionEnabled = true
        taurusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(taurusClicked)))
        
        geminiView.isUserInteractionEnabled = true
        geminiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(geminiClicked)))
        
        cancerView.isUserInteractionEnabled = true
        cancerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancerClicked)))
        
        leoView.isUserInteractionEnabled = true
        leoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leoClicked)))
        
        virgoView.isUserInteractionEnabled = true
        virgoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(virgaClicked)))
        
        libraView.isUserInteractionEnabled = true
        libraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(libraClicked)))
        
        scorpioView.isUserInteractionEnabled = true
        scorpioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scorpioClicked)))
        
        sagitariusView.isUserInteractionEnabled = true
        sagitariusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sagittariusClicked)))
        
        capricornusView.isUserInteractionEnabled = true
        capricornusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(capricornClicked)))
        
        aquariusView.isUserInteractionEnabled = true
        aquariusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aquariusClicked)))
        
        piscesView.isUserInteractionEnabled = true
        piscesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(piscesClicked)))
      
        
        ProgressHUDShow(text: "")
        getHoroscopeModel { horoscopeModel, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.horoscopeModel = horoscopeModel
            }
        }
      
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func ariesClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.aries ?? "", sign: "Aries")
        }
    }
    
    @objc func taurusClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.taurus ?? "", sign: "Taurus")
        }
    }
    @objc func geminiClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.gemini ?? "", sign: "Gemini")
        }
    }
    @objc func cancerClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.cancer ?? "", sign: "Cancer")
        }
    }
    @objc func leoClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.leo ?? "", sign: "Leo")
        }
    }
    @objc func virgaClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.virgo ?? "", sign: "Virgo")
        }
    }
    @objc func libraClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.libra ?? "", sign: "Libra")
        }
    }
    @objc func scorpioClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.scorpio ?? "", sign: "Scorpio")
        }
    }
    @objc func sagittariusClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.sagittarius ?? "", sign: "Sagittarius")
        }
    }
    @objc func capricornClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.capricorn ?? "", sign: "Capricorn")
        }
    }
    @objc func aquariusClicked() {
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.aquarius ?? "", sign: "Aquarius")
        }
    }
    @objc func piscesClicked(){
        if let horoscopeModel = horoscopeModel {
            self.showResult(horoscope: horoscopeModel.pisces ?? "", sign: "Pisces")
        }
    }
    
    @objc func showResult(horoscope : String, sign : String){
        let value = ["sign" : sign, "result" : horoscope]
        performSegue(withIdentifier: "myHoroscopeSeg", sender: value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myHoroscopeSeg" {
            if let VC = segue.destination as? MyHoroscopeViewController {
                if let value = sender as? [String : String]{
                    VC.myHoroscope = value["sign"]
                    VC.result = value["result"]
                }
            }
        }
    }
}
