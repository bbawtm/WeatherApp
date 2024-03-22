//
//  ForecastProtocol.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation
import CoreLocation


struct WeatherData {
    struct Main {
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
        
        enum Code {
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

    struct Wind {
        let speed: Double
        let degrees: Int
        let gust: Double?
    }

    let timestamp: Int
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
