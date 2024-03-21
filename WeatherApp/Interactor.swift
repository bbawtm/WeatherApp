//
//  Interactor.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import Foundation


protocol Service {
    init(_ globals: [String: Any?])
}


class Interactor {
    
    public static let instance = Interactor()
    
    private var dependencies: [String: Any] = [:]
    private let globals: [String: Any?]  // TODO: Make lambda for fetching objects instead of `globals`
    
    private init() {
        globals = [
            "openWeatherToken": Bundle.main.object(forInfoDictionaryKey: "Open Weather token"),
        ]
    }
    
    public func getService<T: Service>(for type: T.Type) -> T {
        let key = String(describing: type)
        
        if let ref = dependencies[key] as? T {
            return ref
        }
        
        let ref = type.init(globals)
        dependencies[key] = ref
        return ref
    }
    
}
