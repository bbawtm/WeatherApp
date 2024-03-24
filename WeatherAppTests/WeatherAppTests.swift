//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Vadim Popov on 19.03.2024.
//

import CoreLocation

import XCTest
@testable import WeatherApp


final class WeatherAppTests: XCTestCase {
    
    let coordinatesToTest = [
        CLLocationCoordinate2DMake(59.9104, 30.2842),
        CLLocationCoordinate2DMake(29.978479, -91.973998),
        CLLocationCoordinate2DMake(-27.3106, -113.6213),
        CLLocationCoordinate2DMake(43.6249, 108.9219),
        CLLocationCoordinate2DMake(5.3346, 27.8263),
        CLLocationCoordinate2DMake(67.4297, 134.7985),
        CLLocationCoordinate2DMake(12.9212, -152.6951),
        CLLocationCoordinate2DMake(40.5233, 86.7886),
        CLLocationCoordinate2DMake(6.9624, -40.2732),
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMomentumOWFS() throws {
        let forecastService: ForecastProtocol = Interactor.instance.getService(for: OpenWeatherForecast.self)
        
        coordinatesToTest.enumerated().forEach { testIndex, coordinates in
            let semaphore = DispatchSemaphore(value: 0)
            
            forecastService.momentumPrediction(
                coordinate: coordinates,
                completion: { weatherData in
                    XCTAssertNotNil(weatherData)
                    semaphore.signal()
                }
            )
            semaphore.wait()
        }
    }
    
    func testLongTermOWFS() throws {
        let forecastService: ForecastProtocol = Interactor.instance.getService(for: OpenWeatherForecast.self)
        
        coordinatesToTest.enumerated().forEach { testIndex, coordinates in
            let semaphore = DispatchSemaphore(value: 0)
            
            forecastService.longTermPrediction(
                coordinate: coordinates,
                completion: { weatherDataList in
                    XCTAssertNotNil(weatherDataList)
                    semaphore.signal()
                }
            )
            semaphore.wait()
        }
    }
    
    func testCacheStorage() {
        let cacheStorage: CacheStorage<String, String> = Interactor.instance.getService(for: CacheStorage.self)
        
        XCTAssertNil(cacheStorage.object(forKey: "a"))
        XCTAssertNil(cacheStorage.object(forKey: "b"))
        
        cacheStorage.setObject("aaa", forKey: "a")
        XCTAssertEqual(cacheStorage.object(forKey: "a"), "aaa")
        XCTAssertNil(cacheStorage.object(forKey: "b"))
        XCTAssertEqual(cacheStorage.object(forKey: "a"), "aaa")
        
        cacheStorage.setObject("bbb", forKey: "b")
        XCTAssertEqual(cacheStorage.object(forKey: "a"), "aaa")
        XCTAssertEqual(cacheStorage.object(forKey: "b"), "bbb")
        XCTAssertEqual(cacheStorage.object(forKey: "b"), "bbb")
        XCTAssertEqual(cacheStorage.object(forKey: "a"), "aaa")
        
        cacheStorage.removeObject(forKey: "a")
        XCTAssertEqual(cacheStorage.object(forKey: "b"), "bbb")
        XCTAssertNil(cacheStorage.object(forKey: "a"))
        
        cacheStorage.setObject("bbb2", forKey: "b")
        XCTAssertEqual(cacheStorage.object(forKey: "b"), "bbb2")
        XCTAssertNil(cacheStorage.object(forKey: "a"))
        
        cacheStorage.setObject("aaa2", forKey: "a")
        XCTAssertEqual(cacheStorage.object(forKey: "a"), "aaa2")
        XCTAssertEqual(cacheStorage.object(forKey: "b"), "bbb2")
        
        cacheStorage.removeObject(forKey: "a")
        cacheStorage.removeObject(forKey: "b")
        XCTAssertNil(cacheStorage.object(forKey: "a"))
        XCTAssertNil(cacheStorage.object(forKey: "b"))
    }

}
