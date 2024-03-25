//
//  RealLocationModel.swift
//  WeatherApp
//
//  Created by Vadim Popov on 25.03.2024.
//

import Foundation
import Combine
import CoreLocation


class RealLocationModel: NSObject, LocationModelProtocol {
    private let publisher = CurrentValueSubject<CLLocationCoordinate2D?, Error>(nil)
    private let locationManager = CLLocationManager()
    
    private(set) lazy var updationPublisher = publisher.eraseToAnyPublisher()
    
    func setup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = 15000
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        publisher.send(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation {
            publisher.send(currentLocation)
        }
    }
    
    public var currentLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    public func requestCurrentLocationRepresentation(completion: @escaping (String) -> Void) {
        return Self.requestLocationRepresentation(locationManager.location, completion: completion)
    }
}
