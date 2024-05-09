//
//  WeatherReportViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 01/02/24.
//

import UIKit

class WeatherReportViewController : UIViewController {
    
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var windLbl: UILabel!
    @IBOutlet weak var humidityView: UIView!
    @IBOutlet weak var humdityLbl: UILabel!
    @IBOutlet weak var uvIndexView: UIView!
    @IBOutlet weak var unIndexLbl: UILabel!
    @IBOutlet weak var visibilityView: UIView!
    @IBOutlet weak var visibilityLbl: UILabel!
    @IBOutlet weak var pressureView: UIView!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet var topView: UIView!
    var weatherModel : WeatherModel?
    @IBOutlet var mView: UIView!
    override func viewDidLoad() {
        
        guard let weatherModel = weatherModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
            return
            
        }
        
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))
        
        
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))


        locationLbl.text = weatherModel.current!.city ?? ""
        feelsLikeTemp.text = "\(weatherModel.current!.feelsLike!)°C"
        
        tempView.layer.cornerRadius = 8
        tempView.dropShadow()
        tempLbl.text = "\(String(format: "%.1f", weatherModel.current!.temp!))°C"
        
        windView.layer.cornerRadius = 8
        windView.dropShadow()
        windLbl.text = "\(weatherModel.current!.windSpeed!)/km"
        
        humidityView.layer.cornerRadius = 8
        humidityView.dropShadow()
        humdityLbl.text = "\(weatherModel.current!.humidity!)%"
        
        uvIndexView.layer.cornerRadius = 8
        uvIndexView.dropShadow()
        
        
        unIndexLbl.text = "\(String(format: "%.2f", weatherModel.current!.uvi! * 11)) of 11"
        
        visibilityView.layer.cornerRadius = 8
        visibilityView.dropShadow()
        visibilityLbl.text = "\(Double(weatherModel.current!.visibility!) / 1000.0) km"
        
        pressureView.layer.cornerRadius = 8
        pressureView.dropShadow()
        pressureLbl.text = "\(weatherModel.current!.pressure!) hPa"
    }
    
    @objc func backViewClicked() {
        dismiss(animated: true)
    }

   
}
