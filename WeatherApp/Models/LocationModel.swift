//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Vadim Popov on 21.03.2024.
//

import Foundation
import CoreLocation
import Combine


class LocationModel: NSObject, CLLocationManagerDelegate {
    
    public static let instance = LocationModel()
    
    public let updationPublisher = CurrentValueSubject<CLLocationCoordinate2D?, Error>(nil)
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
    }
    
    func requestAppropriateAuthorization() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = 15000
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        updationPublisher.send(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation {
            updationPublisher.send(currentLocation)
        }
    }
    
    public var currentLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    public func requestCurrentLocationRepresentation(completion: @escaping (String) -> Void) {
        let undefinedLocationText = "Undefined location"
        
        guard let location = locationManager.location else {
            completion(undefinedLocationText)
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(
            location,
            preferredLocale: Locale(identifier: "en_US")
        ) { listPlacemark, error in
            if let representation = listPlacemark?.first?.name {
                completion(representation)
                
            } else {
                completion(undefinedLocationText)
            }
        }
    }
    
}
