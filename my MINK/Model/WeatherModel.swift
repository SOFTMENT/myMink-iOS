import Foundation

// MARK: - WeatherModel
class WeatherModel: Codable {
    var lat, lon: Double?
    var timezone: String?
    var timezoneOffset: Int?
    var current: Current?

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current
    }

    init(lat: Double?, lon: Double?, timezone: String?, timezoneOffset: Int?, current: Current?) {
        self.lat = lat
        self.lon = lon
        self.timezone = timezone
        self.timezoneOffset = timezoneOffset
        self.current = current
    }
}

// MARK: - Current
class Current: Codable {
    var dt, sunrise, sunset: Int?
    var temp, feelsLike: Double?
    var pressure, humidity: Int?
    var dewPoint, uvi: Double?
    var clouds, visibility: Int?
    var windSpeed: Double?
    var windDeg: Int?
    var city : String?
    var windGust: Double?
    var weather: [Weather]?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case uvi, clouds, visibility
        case windSpeed = "wind_speed"
        case city = "city_name"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
    }

    init(dt: Int?, sunrise: Int?, sunset: Int?, temp: Double?, feelsLike: Double?, pressure: Int?, humidity: Int?, dewPoint: Double?, uvi: Double?, clouds: Int?, visibility: Int?, windSpeed: Double?, windDeg: Int?, windGust: Double?, weather: [Weather]?) {
        self.dt = dt
        self.sunrise = sunrise
        self.sunset = sunset
        self.temp = temp
        self.feelsLike = feelsLike
        self.pressure = pressure
        self.humidity = humidity
        self.dewPoint = dewPoint
        self.uvi = uvi
       
        self.clouds = clouds
        self.visibility = visibility
        self.windSpeed = windSpeed
        self.windDeg = windDeg
        self.windGust = windGust
        self.weather = weather
    }
}

// MARK: - Weather
class Weather: Codable {
    var id: Int?
    var main, description, icon: String?

    init(id: Int?, main: String?, description: String?, icon: String?) {
        self.id = id
        self.main = main
        self.description = description
        self.icon = icon
    }
}
