//
//  SearchLocationModel.swift
//  WeatherApp
//
//  Created by Vadim Popov 25.03.2024.
//

import Foundation
import Combine
import CoreLocation


class SearchLocationModel: NSObject, LocationModelProtocol {
    public let publisher = CurrentValueSubject<CLLocation?, Error>(nil)
    
    private(set) lazy var updationPublisher = publisher.map({ location in
        location?.coordinate
    }).eraseToAnyPublisher()
    
    func setup() {
    }
    
    public func requestCurrentLocationRepresentation(completion: @escaping (String) -> Void) {
        return Self.requestLocationRepresentation(publisher.value, completion: completion)
    }
}
