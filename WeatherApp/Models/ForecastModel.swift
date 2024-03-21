//
//  ForecastModel.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation
import CoreLocation
import Combine


private class CacheKey: Hashable {
    private let coordinateLatitude: Double
    private let coordinateLongitude: Double
//    var datetime = Date()
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinateLatitude = coordinate.latitude
        self.coordinateLongitude = coordinate.longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinateLatitude, longitude: coordinateLongitude)
    }
    
    static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
        lhs.coordinateLatitude == rhs.coordinateLatitude && lhs.coordinateLongitude == rhs.coordinateLongitude /*&& lhs.datetime == rhs.datetime*/
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinateLatitude)
        hasher.combine(coordinateLongitude)
//        hasher.combine(datetime)
    }
}

private class CacheValue {
    let weatherData: WeatherData
    
    init(weatherData: WeatherData) {
        self.weatherData = weatherData
    }
}

struct ObservationTimerKey: Hashable {
    enum UsageType {
        case momentum
        case longTerm
    }
    
    let usageType: UsageType
    let coordinateLatitude: Double
    let coordinateLongitude: Double
}


class ForecastModel {
    
    public static let instance = ForecastModel()
    
    private var observationTimers: [ObservationTimerKey: Timer] = [:]
    private weak var forecastService: ForecastProtocol? = Interactor.instance.getService(for: OpenWeatherForecast.self)
    private let cacheStorage = NSCache<CacheKey, CacheValue>()
    
    private init() {
    }
    
    public func momentumForecast(forCoordinate coordinate: CLLocationCoordinate2D) -> CurrentValueSubject<WeatherData?, Error> {
        let transformedCoordinate = appropriateScalingTransform(coordinate: coordinate)
        let publisher = CurrentValueSubject<WeatherData?, Error>(nil)
        
        let observationTimerKey = ObservationTimerKey(
            usageType: .momentum,
            coordinateLatitude: transformedCoordinate.latitude,
            coordinateLongitude: transformedCoordinate.longitude
        )
        let observationClosure = { [weak self, weak publisher] in
            self?.forecastService?.momentumPrediction(coordinate: transformedCoordinate, completion: { [weak publisher] weatherData in
                publisher?.send(weatherData)
            })
        }
        
        observationClosure()
        
        observationTimers[observationTimerKey] = Timer.scheduledTimer(
            withTimeInterval: 3600,
            repeats: true,
            block: { _ in observationClosure() }
        )
        
        return publisher
    }
    
    public func longTermForecast(forCoordinate coordinate: CLLocationCoordinate2D) -> CurrentValueSubject<[WeatherData]?, Error> {
        let transformedCoordinate = appropriateScalingTransform(coordinate: coordinate)
        let publisher = CurrentValueSubject<[WeatherData]?, Error>(nil)
        
        let observationTimerKey = ObservationTimerKey(
            usageType: .momentum,
            coordinateLatitude: transformedCoordinate.latitude,
            coordinateLongitude: transformedCoordinate.longitude
        )
        
        observationTimers[observationTimerKey] = Timer.scheduledTimer(
            withTimeInterval: 3600,
            repeats: true,
            block: { [weak self, weak publisher] _ in
                self?.forecastService?.longTermPrediction(coordinate: transformedCoordinate, completion: { [weak publisher] weatherData in
                    publisher?.send(weatherData)
                })
            }
        )
        
        return publisher
    }
    
    public func removeTimer(forKey key: ObservationTimerKey) {
        observationTimers.removeValue(forKey: key)
    }
    
    
    
    
//    public func currentForecast(coordinate: CLLocationCoordinate2D) -> WeatherData? {
//        let cacheKey = CacheKey(coordinate)
//        
//        if let value = cacheStorage.object(forKey: cacheKey) {
//            let weatherData = value.weatherData
//            
//            if Date.now.timeIntervalSince1970 - weatherData.date.timeIntervalSince1970 < 1.5 * 3600 {
//                return weatherData

    
    private func appropriateScalingTransform(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (coordinate.latitude * 10).rounded() / 10,
            longitude: (coordinate.longitude * 10).rounded() / 10
        )
    }
    
}
