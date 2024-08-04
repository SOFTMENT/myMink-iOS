//
//  WeatherReportViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 01/02/24.
//

import UIKit

class WeatherReportViewController: UIViewController {
    
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
    @IBOutlet var mView: UIView!
    
    var weatherModel: WeatherModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let weatherModel = weatherModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        setupUI()
        populateWeatherData(weatherModel: weatherModel)
    }
    
    private func setupUI() {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        setupBackView()
        setupTopView()
        
        setupWeatherView(tempView)
        setupWeatherView(windView)
        setupWeatherView(humidityView)
        setupWeatherView(uvIndexView)
        setupWeatherView(visibilityView)
        setupWeatherView(pressureView)
    }
    
    private func setupBackView() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(backViewClicked)
        ))
    }
    
    private func setupTopView() {
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(backViewClicked)
        ))
    }
    
    private func setupWeatherView(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.dropShadow()
    }
    
    private func populateWeatherData(weatherModel: WeatherModel) {
        locationLbl.text = weatherModel.current?.city ?? ""
        feelsLikeTemp.text = "\(weatherModel.current?.feelsLike ?? 0)°C"
        
        tempLbl.text = "\(String(format: "%.1f", weatherModel.current?.temp ?? 0))°C"
        windLbl.text = "\(weatherModel.current?.windSpeed ?? 0)/km"
        humdityLbl.text = "\(weatherModel.current?.humidity ?? 0)%"
        unIndexLbl.text = "\(String(format: "%.2f", (weatherModel.current?.uvi ?? 0) * 11)) of 11"
        visibilityLbl.text = "\(Double(weatherModel.current?.visibility ?? 0) / 1000.0) km"
        pressureLbl.text = "\(weatherModel.current?.pressure ?? 0) hPa"
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
}
