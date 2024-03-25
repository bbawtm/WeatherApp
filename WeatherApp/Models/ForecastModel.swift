//
//  ForecastModel.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation
import CoreLocation
import Combine


extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        (lhs.latitude, lhs.longitude) == (rhs.latitude, rhs.longitude)
    }
}

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}


private class CacheKey: Hashable, Codable {
    private let usageType: ForecastModel.UsageType
    private let coordinate: CLLocationCoordinate2D
    
    private enum CodingKeys: String, CodingKey {
        case usageType
        case coordinate
    }
    
    init(usageType: ForecastModel.UsageType, coordinate: CLLocationCoordinate2D) {
        self.usageType = usageType
        self.coordinate = coordinate
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.usageType = try container.decode(ForecastModel.UsageType.self, forKey: .usageType)
        self.coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(usageType, forKey: .usageType)
        try container.encode(coordinate, forKey: .coordinate)
    }
    
    static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
        (lhs.usageType, lhs.coordinate) == (rhs.usageType, rhs.coordinate)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(usageType)
        hasher.combine(coordinate)
    }
}

private class CacheValue: Codable {
    let weatherDataList: [WeatherData]
    
    init(weatherData: WeatherData) {
        self.weatherDataList = [weatherData]
    }
    
    init(weatherDataList: [WeatherData]) {
        self.weatherDataList = weatherDataList
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.weatherDataList = try container.decode([WeatherData].self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(weatherDataList)
    }
}


class ForecastModel {
    
    enum UsageType: Codable {
        case momentum
        case longTerm
    }
    
    struct ObservationTimerKey: Hashable {
        let usageType: UsageType
        let coordinateLatitude: Double
        let coordinateLongitude: Double
    }
    
    public static let instance = ForecastModel()
    
    private let networkUsagePublisher = PassthroughSubject<Int, Error>()
    private var observationTimers: [ObservationTimerKey: Timer] = [:]
    private weak var forecastService: ForecastProtocol? = Interactor.instance.getService(for: OpenWeatherForecast.self)
    private weak var cacheStorage: CacheStorage<CacheKey, CacheValue>? = Interactor.instance.getService(for: CacheStorage.self)
    
    private init() {
    }
    
    public func momentumForecast(forCoordinate coordinate: CLLocationCoordinate2D) -> CurrentValueSubject<WeatherData?, Error> {
        return requestForecast(ofType: .momentum, forCoordinate: coordinate)
    }
    
    public func longTermForecast(forCoordinate coordinate: CLLocationCoordinate2D) -> CurrentValueSubject<[WeatherData]?, Error> {
        return requestForecast(ofType: .longTerm, forCoordinate: coordinate)
    }
    
    public func stopForecastUpdations() {
        observationTimers.forEach { _, timer in
            timer.invalidate()
        }
        observationTimers.removeAll()
    }
    
    public func networkUsage() -> AnyPublisher<Int, Error> {
        return networkUsagePublisher.eraseToAnyPublisher()
    }
    
    private func requestForecast<T>(
        ofType usageType: UsageType,
        forCoordinate coordinate: CLLocationCoordinate2D
    ) -> CurrentValueSubject<T?, Error> {
        
        let transformedCoordinate = appropriateScalingTransform(coordinate: coordinate)
        let publisher = CurrentValueSubject<T?, Error>(cacheValue(forUsageType: usageType, coordinate: transformedCoordinate))
        
        let observationTimerKey = ObservationTimerKey(
            usageType: .momentum,
            coordinateLatitude: transformedCoordinate.latitude,
            coordinateLongitude: transformedCoordinate.longitude
        )
        
        let observationClosure: () -> ()
        switch usageType {
        case .momentum:
            observationClosure = { [weak self, weak publisher] in
                self?.networkUsagePublisher.send(1)
                self?.forecastService?.momentumPrediction(coordinate: transformedCoordinate, completion: { [weak self, weak publisher] weatherData in
                    self?.setCacheValue(weatherData, forUsageType: usageType, coordinate: transformedCoordinate)
                    publisher?.send(weatherData as? T)
                    self?.networkUsagePublisher.send(-1)
                })
            }
        
        case .longTerm:
            observationClosure = { [weak self, weak publisher] in
                self?.networkUsagePublisher.send(1)
                self?.forecastService?.longTermPrediction(
                    coordinate: transformedCoordinate,
                    completion: { [weak self, weak publisher] weatherDataList in
                        self?.setCacheValue(weatherDataList, forUsageType: usageType, coordinate: transformedCoordinate)
                        publisher?.send(weatherDataList as? T)
                        self?.networkUsagePublisher.send(-1)
                    }
                )
            }
        }
        
        observationClosure()
        
        observationTimers[observationTimerKey] = Timer.scheduledTimer(
            withTimeInterval: 0.25 * 3600,
            repeats: true,
            block: { _ in observationClosure() }
        )
        
        return publisher
    }
    
    private func cacheValue<T>(forUsageType usageType: UsageType, coordinate: CLLocationCoordinate2D) -> Optional<T> {
        let cacheKey = CacheKey(usageType: usageType, coordinate: coordinate)
        
        return switch usageType {
        case .momentum: {
            guard
                let value = cacheStorage?.object(forKey: cacheKey),
                value.weatherDataList.count == 1
            else { return nil }
            
            let weatherData = value.weatherDataList[0]
            
            if Date.now.timeIntervalSince1970 - weatherData.date.timeIntervalSince1970 < 2.5 * 3600 {
                return weatherData as? T
            }
            
            cacheStorage?.removeObject(forKey: cacheKey)
            
            let longTermValues: [WeatherData]? = cacheValue(forUsageType: .longTerm, coordinate: coordinate)
            var bestData: WeatherData? = nil
            var bestScore = Date.now.timeIntervalSince1970
            
            longTermValues?.forEach { predictionData in
                let distance = abs(Date.now.timeIntervalSince1970 - predictionData.date.timeIntervalSince1970)
                
                if distance < 4 * 3600 && Date.now.timeIntervalSince1970 > predictionData.date.timeIntervalSince1970 - 0.5 * 3600 {
                    let score = Date.now.timeIntervalSince1970 - predictionData.date.timeIntervalSince1970
                    
                    if score < bestScore {
                        bestData = predictionData
                        bestScore = score
                    }
                }
            }
            
            if bestData == nil {
                cacheStorage?.removeObject(forKey: CacheKey(usageType: .longTerm, coordinate: coordinate))
            }
            
            return bestData as? T
        }()
            
        case .longTerm: {
            guard let value = cacheStorage?.object(forKey: cacheKey) else { return nil }
            return value.weatherDataList as? T
        }()
        }
    }
    
    private func setCacheValue(_ value: WeatherData?, forUsageType usageType: UsageType, coordinate: CLLocationCoordinate2D) {
        guard let value else { return }
        
        cacheStorage?.setObject(
            CacheValue(weatherData: value),
            forKey: CacheKey(usageType: .momentum, coordinate: coordinate)
        )
    }
    
    private func setCacheValue(_ value: [WeatherData]?, forUsageType usageType: UsageType, coordinate: CLLocationCoordinate2D) {
        guard let value else { return }
        
        cacheStorage?.setObject(
            CacheValue(weatherDataList: value),
            forKey: CacheKey(usageType: .longTerm, coordinate: coordinate)
        )
    }
    
    private func appropriateScalingTransform(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (coordinate.latitude * 10).rounded() / 10,
            longitude: (coordinate.longitude * 10).rounded() / 10
        )
    }
    
}
