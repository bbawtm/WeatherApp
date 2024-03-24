//
//  ForecastProtocol.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation
import CoreLocation


struct WeatherData {
    struct Main: Codable {
        let temperature: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let temperatureMin: Double
        let temperatureMax: Double
        let seaLevel: Int?
        let groundLevel: Int?
    }

    struct Weather {
        
        enum Code: Codable {
            case thunderstorm
            case drizzle
            case rain
            case snow
            case atmosphere
            case clear
            case clouds
            
            static func from(string: String) -> Self {
                if string == "Thunderstorm" {
                    return .thunderstorm
                }
                
                if string == "Drizzle" {
                    return .drizzle
                }
                
                if string == "Rain" {
                    return .rain
                }
                
                if string == "Snow" {
                    return .snow
                }
                
                if string == "Atmosphere" {
                    return .atmosphere
                }
                
                if string == "Clear" {
                    return .clear
                }
                
                return .clouds
            }
        }
        
        let code: Code
        let title: String
        let description: String
        
        let cloudsVolume: Int?
        let visibility: Int?
        let rain: Double?
        let rainProbability: Double?
        let snow: Double?
        let wind: Wind?
    }

    struct Wind: Codable {
        let speed: Double
        let degrees: Int
        let gust: Double?
    }

    let timestamp: TimeInterval
    let timezone: Int
    let coordinate: CLLocationCoordinate2D
    
    let main: Main
    let weather: Weather
    
    let sunrise: Int?
    let sunset: Int?
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}


protocol ForecastProtocol: Service, AnyObject {
    
    func momentumPrediction(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping (WeatherData?) -> Void
    )
    
    func longTermPrediction(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping ([WeatherData]?) -> Void
    )
    
}


extension WeatherData: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        timezone = try container.decode(Int.self, forKey: .timezone)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        main = try container.decode(Main.self, forKey: .main)
        weather = try container.decode(Weather.self, forKey: .weather)
        sunrise = try container.decodeIfPresent(Int.self, forKey: .sunrise)
        sunset = try container.decodeIfPresent(Int.self, forKey: .sunset)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(main, forKey: .main)
        try container.encode(weather, forKey: .weather)
        try container.encodeIfPresent(sunrise, forKey: .sunrise)
        try container.encodeIfPresent(sunset, forKey: .sunset)
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case timezone
        case coordinate
        case main
        case weather
        case sunrise
        case sunset
    }
}

extension WeatherData.Weather: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Code.self, forKey: .code)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        cloudsVolume = try container.decodeIfPresent(Int.self, forKey: .cloudsVolume)
        visibility = try container.decodeIfPresent(Int.self, forKey: .visibility)
        rain = try container.decodeIfPresent(Double.self, forKey: .rain)
        rainProbability = try container.decodeIfPresent(Double.self, forKey: .rainProbability)
        snow = try container.decodeIfPresent(Double.self, forKey: .snow)
        wind = try container.decodeIfPresent(WeatherData.Wind.self, forKey: .wind)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(cloudsVolume, forKey: .cloudsVolume)
        try container.encodeIfPresent(visibility, forKey: .visibility)
        try container.encodeIfPresent(rain, forKey: .rain)
        try container.encodeIfPresent(rainProbability, forKey: .rainProbability)
        try container.encodeIfPresent(snow, forKey: .snow)
        try container.encodeIfPresent(wind, forKey: .wind)
    }
    
    private enum CodingKeys: String, CodingKey {
        case code, title, description, cloudsVolume, visibility, rain, rainProbability, snow, wind
    }
}
