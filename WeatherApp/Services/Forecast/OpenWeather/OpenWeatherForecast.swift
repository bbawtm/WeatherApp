//
//  OpenWeatherForecast.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation
import CoreLocation


class OpenWeatherForecast: ForecastProtocol {
    
    private let token: String
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    required init(_ globals: [String : Any?]) {
        guard let token = globals["openWeatherToken"] as? String else {
            fatalError("OpenWeatherForecast: token not found")
        }
        
        self.token = token
    }
    
    func momentumPrediction(coordinate: CLLocationCoordinate2D, completion: @escaping (WeatherData?) -> Void) {
        let request = URLRequest(
            url: URL(string: "https://api.openweathermap.org/data/2.5/weather" +
                "?lat=\(coordinate.latitude)" +
                "&lon=\(coordinate.longitude)" +
                "&appid=\(token)"
            )!
        )
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let parsedDict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String : Any]
                
                guard parsedDict["cod"] as! Int == 200 else {
                    completion(nil)
                    return
                }
                
                let mainData = parsedDict["main"] as! [String: Any]
                let sysData = parsedDict["sys"] as! [String: Any]
                let coordData = parsedDict["coord"] as? [String: Any]
                let weatherData = (parsedDict["weather"] as! [[String: Any]])[0]
                let windData = parsedDict["wind"] as? [String: Any]
                
                let result = WeatherData(
                    timestamp: TimeInterval(parsedDict["dt"] as! Int),
                    timezone: parsedDict["timezone"] as! Int,
                    
                    coordinate: CLLocationCoordinate2D(
                        latitude: coordData?["lat"] as! Double,
                        longitude: coordData?["lon"] as! Double
                    ),
                    
                    main: .init(
                        temperature: (mainData["temp"] as! Double) - 273.15,
                        feelsLike: mainData["feels_like"] as! Double - 273.15,
                        pressure: mainData["pressure"] as! Int,
                        humidity: mainData["humidity"] as! Int,
                        temperatureMin: (mainData["temp_min"] as! Double) - 273.15,
                        temperatureMax: (mainData["temp_max"] as! Double) - 273.15,
                        seaLevel: mainData["sea_level"] as? Int,
                        groundLevel: mainData["ground_level"] as? Int
                    ),
                    
                    weather: .init(
                        code: .from(string: weatherData["main"] as! String),
                        title: weatherData["main"] as! String,
                        description: weatherData["description"] as! String,
                        cloudsVolume: (parsedDict["clouds"] as? [String: Any])?["all"] as? Int,
                        visibility: parsedDict["visibility"] as? Int,
                        rain: (parsedDict["rain"] as? [String: Any])?["3h"] as? Double,
                        rainProbability: nil,
                        snow: (parsedDict["snow"] as? [String: Any])?["3h"] as? Double,
                        
                        wind: windData != nil ? .init(
                            speed: windData!["speed"] as! Double,
                            degrees: windData!["deg"] as! Int,
                            gust: windData?["gust"] as? Double
                        ) : nil
                    ),
                    
                    sunrise: sysData["sunrise"] as? Int,
                    sunset: sysData["sunset"] as? Int
                )
                
                completion(result)
                
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func longTermPrediction(coordinate: CLLocationCoordinate2D, completion: @escaping ([WeatherData]?) -> Void) {
        let request = URLRequest(
            url: URL(string: "https://api.openweathermap.org/data/2.5/forecast" +
                "?lat=\(coordinate.latitude)" +
                "&lon=\(coordinate.longitude)" +
                "&appid=\(token)"
            )!
        )
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let parsedDict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String : Any]
                var result: [WeatherData] = []
                
                guard parsedDict["cod"] as! String == "200" else {
                    completion(nil)
                    return
                }
                
                let listData = parsedDict["list"] as! [[String: Any]]
                let cityData = parsedDict["city"] as! [String: Any]
                let coordData = cityData["coord"] as? [String: Any]
                
                listData.forEach { listItemData in
                    let mainData = listItemData["main"] as! [String: Any]
                    let weatherData = (listItemData["weather"] as! [[String: Any]])[0]
                    let windData = listItemData["wind"] as? [String: Any]
                    
                    let resultItem = WeatherData(
                        timestamp: TimeInterval(listItemData["dt"] as! Int),
                        timezone: cityData["timezone"] as! Int,
                        
                        coordinate: CLLocationCoordinate2D(
                            latitude: coordData?["lat"] as! Double,
                            longitude: coordData?["lon"] as! Double
                        ),
                        
                        main: .init(
                            temperature: (mainData["temp"] as! Double) - 273.15,
                            feelsLike: mainData["feels_like"] as! Double - 273.15,
                            pressure: mainData["pressure"] as! Int,
                            humidity: mainData["humidity"] as! Int,
                            temperatureMin: (mainData["temp_min"] as! Double) - 273.15,
                            temperatureMax: (mainData["temp_max"] as! Double) - 273.15,
                            seaLevel: mainData["sea_level"] as? Int,
                            groundLevel: mainData["grnd_level"] as? Int
                        ),
                        
                        weather: .init(
                            code: .from(string: weatherData["main"] as! String),
                            title: weatherData["main"] as! String,
                            description: weatherData["description"] as! String,
                            cloudsVolume: (listItemData["clouds"] as? [String: Any])?["all"] as? Int,
                            visibility: listItemData["visibility"] as? Int,
                            rain: (listItemData["rain"] as? [String: Any])?["3h"] as? Double,
                            rainProbability: listItemData["pop"] as? Double,
                            snow: (listItemData["snow"] as? [String: Any])?["3h"] as? Double,
                            
                            wind: windData != nil ? .init(
                                speed: windData!["speed"] as! Double,
                                degrees: windData!["deg"] as! Int,
                                gust: windData?["gust"] as? Double
                            ) : nil
                        ),
                        
                        sunrise: cityData["sunrise"] as? Int,
                        sunset: cityData["sunset"] as? Int
                    )
                    result.append(resultItem)
                }
                
                completion(result)
                
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
}
