//
//  DailyHoroscopeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/02/24.
//

import UIKit

class DailyHoroscopeViewController: UIViewController {

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
    
    var token: String?
    var horoscopeModel: HoroscopeModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchHoroscopeModel()
    }
    
    private func setupUI() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        configureViewGestures()
    }
    
    private func configureViewGestures() {
        let horoscopeViews: [(UIView?, Selector)] = [
            (ariesView, #selector(ariesClicked)),
            (taurusView, #selector(taurusClicked)),
            (geminiView, #selector(geminiClicked)),
            (cancerView, #selector(cancerClicked)),
            (leoView, #selector(leoClicked)),
            (virgoView, #selector(virgoClicked)),
            (libraView, #selector(libraClicked)),
            (scorpioView, #selector(scorpioClicked)),
            (sagitariusView, #selector(sagittariusClicked)),
            (capricornusView, #selector(capricornClicked)),
            (aquariusView, #selector(aquariusClicked)),
            (piscesView, #selector(piscesClicked))
        ]
        
        for (view, selector) in horoscopeViews {
            view?.isUserInteractionEnabled = true
            view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        }
    }

    private func fetchHoroscopeModel() {
        ProgressHUDShow(text: "")
        getHoroscopeModel { [weak self] horoscopeModel, error in
            guard let self = self else { return }
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.horoscopeModel = horoscopeModel
            }
        }
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func ariesClicked() {
        showHoroscope(for: .aries, sign: "Aries")
    }
    
    @objc func taurusClicked() {
        showHoroscope(for: .taurus, sign: "Taurus")
    }
    
    @objc func geminiClicked() {
        showHoroscope(for: .gemini, sign: "Gemini")
    }
    
    @objc func cancerClicked() {
        showHoroscope(for: .cancer, sign: "Cancer")
    }
    
    @objc func leoClicked() {
        showHoroscope(for: .leo, sign: "Leo")
    }
    
    @objc func virgoClicked() {
        showHoroscope(for: .virgo, sign: "Virgo")
    }
    
    @objc func libraClicked() {
        showHoroscope(for: .libra, sign: "Libra")
    }
    
    @objc func scorpioClicked() {
        showHoroscope(for: .scorpio, sign: "Scorpio")
    }
    
    @objc func sagittariusClicked() {
        showHoroscope(for: .sagittarius, sign: "Sagittarius")
    }
    
    @objc func capricornClicked() {
        showHoroscope(for: .capricorn, sign: "Capricorn")
    }
    
    @objc func aquariusClicked() {
        showHoroscope(for: .aquarius, sign: "Aquarius")
    }
    
    @objc func piscesClicked() {
        showHoroscope(for: .pisces, sign: "Pisces")
    }
    
    private func showHoroscope(for si: HoroscopeSign, sign: String) {
        if let horoscopeText = horoscopeModel?.horoscope(for: si) {
            showResult(horoscope: horoscopeText, sign: sign)
        }
    }
    
    private func showResult(horoscope: String, sign: String) {
        let value = ["sign": sign, "result": horoscope]
        performSegue(withIdentifier: "myHoroscopeSeg", sender: value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myHoroscopeSeg", let VC = segue.destination as? MyHoroscopeViewController, let value = sender as? [String: String] {
            VC.myHoroscope = value["sign"]
            VC.result = value["result"]
        }
    }
}

private extension HoroscopeModel {
    func horoscope(for sign: HoroscopeSign) -> String? {
        switch sign {
        case .aries: return aries
        case .taurus: return taurus
        case .gemini: return gemini
        case .cancer: return cancer
        case .leo: return leo
        case .virgo: return virgo
        case .libra: return libra
        case .scorpio: return scorpio
        case .sagittarius: return sagittarius
        case .capricorn: return capricorn
        case .aquarius: return aquarius
        case .pisces: return pisces
        }
    }
}

enum HoroscopeSign {
    case aries, taurus, gemini, cancer, leo, virgo, libra, scorpio, sagittarius, capricorn, aquarius, pisces
}
