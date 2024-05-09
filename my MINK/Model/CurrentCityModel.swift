//
//  CurrentCityModel.swift
//  my MINK
//
//  Created by Vijay Rathore on 26/02/24.
//

import Foundation

// MARK: - CurrentCityModelElement
class CurrentCityModelElement: Codable {
    var name: String?
    var lat, lon: Double?
    var country, state: String?

    init(name: String?, lat: Double?, lon: Double?, country: String?, state: String?) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }
}

typealias CurrentCityModel = [CurrentCityModelElement]
