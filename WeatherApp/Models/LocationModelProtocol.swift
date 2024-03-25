//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Vadim Popov on 21.03.2024.
//

import Foundation
import CoreLocation
import Combine


protocol LocationModelProtocol: CLLocationManagerDelegate {
    var updationPublisher: AnyPublisher<CLLocationCoordinate2D?, Error> { get }
    
    func setup()
    func requestCurrentLocationRepresentation(completion: @escaping (String) -> Void)
}

extension LocationModelProtocol {
    static func requestLocationRepresentation(_ location: CLLocation?, completion: @escaping (String) -> Void) {
        let undefinedLocationText = "Undefined location"
        
        guard let location else {
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
