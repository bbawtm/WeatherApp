//
//  MainVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit
import CoreLocation
import Combine


class MainVC: UIViewController {
    
    private weak var forecastModel = ForecastModel.instance
    private weak var locationModel = LocationModel.instance
    
    private var locationSubscriber: AnyCancellable?
    private var momentumForecastSubscriber: AnyCancellable?
    private var longTermForecastSubscriber: AnyCancellable?
    
    private let updateViewMomentumPublisher = CurrentValueSubject<WeatherData?, Error>(nil)
    private let updateViewLongTermPublisher = CurrentValueSubject<[WeatherData]?, Error>(nil)
    
    private let scrollView = UIScrollView()
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "cloud.fill")
        let colorSelected = UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1)
        let colorNonSelected = UIColor.white
        
        tabBarItem = UITabBarItem(
            title: "Today",
            image: icon?.withTintColor(colorNonSelected, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(colorSelected, renderingMode: .alwaysOriginal)
        )
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colorNonSelected], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colorSelected], for: .selected)
        
        return self
    }
    
    // MARK: Head Container
    
    private let headDayDescriptionComponent4 = HeadDayDescriptionComponent4()
    private let headLocationDescriptionComponent4 = HeadLocationDescriptionComponent4()
    
    private lazy var headContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headDayDescriptionComponent4.view)
        container.addSubview(headLocationDescriptionComponent4.view)
        return container
    }()
    
    // MARK: Central Container
    
    private lazy var centralImageComponent4 = CentralImageComponent4(listen: updateViewMomentumPublisher.eraseToAnyPublisher())
    private lazy var centralDegreesComponent4 = CentralDegreesComponent4(listen: updateViewMomentumPublisher.eraseToAnyPublisher())
    private lazy var centralDescriptionComponent4 = CentralDescriptionComponent4(listen: updateViewMomentumPublisher.eraseToAnyPublisher())
    private lazy var centralSubscriptComponent4 = CentralSubscriptComponent4(listen: updateViewMomentumPublisher.eraseToAnyPublisher())
    
    private lazy var centralContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(centralImageComponent4.view)
        container.addSubview(centralDegreesComponent4.view)
        container.addSubview(centralDescriptionComponent4.view)
        container.addSubview(centralSubscriptComponent4.view)
        return container
    }()
    
    // MARK: Badges
    
    private lazy var badgeHumidityComponent4 = BadgeItemComponent4(
        imageName: "humidity",
        titleText: "Humidity",
        defaultValue: "––%",
        valueGetter: { weatherData in
            guard let weatherData else {
                return "––%"
            }
            return "\(Int(weatherData.main.humidity))%"
        },
        listen: updateViewMomentumPublisher.eraseToAnyPublisher()
    )
    
    private lazy var badgeWindComponent4 = BadgeItemComponent4(
        imageName: "wind",
        titleText: "Wind",
        defaultValue: "––m/s",
        valueGetter: { weatherData in
            guard let weatherData, let speed = weatherData.weather.wind?.speed else {
                return "––m/s"
            }
            return "\(Int(speed.rounded()))m/s"
        },
        listen: updateViewMomentumPublisher.eraseToAnyPublisher()
    )
    
    private lazy var badgeSunriseComponent4 = BadgeItemComponent4(
        imageName: "sunrise",
        titleText: "Sunrise",
        defaultValue: "––:––",
        valueGetter: { weatherData in
            guard let weatherData, let sunrise = weatherData.sunrise else {
                return "––:––"
            }
            
            let sunriseDate = Date(timeIntervalSince1970: TimeInterval(sunrise + weatherData.timezone))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            return "\(dateFormatter.string(from: sunriseDate))"
        },
        listen: updateViewMomentumPublisher.eraseToAnyPublisher()
    )
    
    private lazy var badgeSunsetComponent4 = BadgeItemComponent4(
        imageName: "sunset",
        titleText: "Sunset",
        defaultValue: "––:––",
        valueGetter: { weatherData in
            guard let weatherData, let sunset = weatherData.sunset else {
                return "––:––"
            }
            
            let sunsetDate = Date(timeIntervalSince1970: TimeInterval(sunset + weatherData.timezone))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            return "\(dateFormatter.string(from: sunsetDate))"
        },
        listen: updateViewMomentumPublisher.eraseToAnyPublisher()
    )
    
    private lazy var badgesContainer: UIView = {
        let container = UIView()
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badgeHumidityComponent4.view)
        container.addSubview(badgeWindComponent4.view)
        container.addSubview(badgeSunriseComponent4.view)
        container.addSubview(badgeSunsetComponent4.view)
        
        return container
    }()
    
    // MARK: Calendar
    
    private lazy var calendarComponent = CalendarComponent4(listen: updateViewLongTermPublisher)
    
    // MARK: Common
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            
            // Head container

            headDayDescriptionComponent4.view.topAnchor.constraint(equalTo: headContainer.topAnchor),
            headDayDescriptionComponent4.view.leftAnchor.constraint(equalTo: headContainer.leftAnchor),
            
            headLocationDescriptionComponent4.view.topAnchor.constraint(equalTo: headDayDescriptionComponent4.view.bottomAnchor, constant: 7),
            headLocationDescriptionComponent4.view.leftAnchor.constraint(equalTo: headContainer.leftAnchor),
            headLocationDescriptionComponent4.view.bottomAnchor.constraint(equalTo: headContainer.bottomAnchor),
            
            headContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            
            // Central container
            
            centralImageComponent4.view.topAnchor.constraint(equalTo: centralContainer.topAnchor),
            centralImageComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            centralImageComponent4.view.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor, multiplier: 0.5),
            centralImageComponent4.view.heightAnchor.constraint(equalToConstant: 100),
            
            centralDegreesComponent4.view.topAnchor.constraint(equalTo: centralImageComponent4.view.bottomAnchor, constant: 10),
            centralDegreesComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralDescriptionComponent4.view.topAnchor.constraint(equalTo: centralDegreesComponent4.view.bottomAnchor),
            centralDescriptionComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralSubscriptComponent4.view.topAnchor.constraint(equalTo: centralDescriptionComponent4.view.bottomAnchor, constant: 5),
            centralSubscriptComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            centralSubscriptComponent4.view.bottomAnchor.constraint(equalTo: centralContainer.bottomAnchor),
            
            centralContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 30),
            centralContainer.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            
            // Badges container
            
            badgeHumidityComponent4.view.leftAnchor.constraint(equalTo: badgesContainer.leftAnchor, constant: 30),
            badgeHumidityComponent4.view.topAnchor.constraint(equalTo: badgesContainer.topAnchor),
            badgeHumidityComponent4.view.widthAnchor.constraint(lessThanOrEqualTo: badgesContainer.widthAnchor, multiplier: 0.5, constant: -30*1.5),
            
            badgeWindComponent4.view.leftAnchor.constraint(equalTo: badgeHumidityComponent4.view.rightAnchor, constant: 30),
            badgeWindComponent4.view.rightAnchor.constraint(equalTo: badgesContainer.rightAnchor, constant: -30),
            badgeWindComponent4.view.topAnchor.constraint(equalTo: badgesContainer.topAnchor),
            badgeWindComponent4.view.widthAnchor.constraint(lessThanOrEqualTo: badgesContainer.widthAnchor, multiplier: 0.5, constant: -30*1.5),
            
            badgeSunriseComponent4.view.leftAnchor.constraint(equalTo: badgesContainer.leftAnchor, constant: 30),
            badgeSunriseComponent4.view.topAnchor.constraint(equalTo: badgeHumidityComponent4.view.bottomAnchor, constant: 30),
            badgeSunriseComponent4.view.bottomAnchor.constraint(equalTo: badgesContainer.bottomAnchor),
            badgeSunriseComponent4.view.widthAnchor.constraint(lessThanOrEqualTo: badgesContainer.widthAnchor, multiplier: 0.5, constant: -30*1.5),
            
            badgeSunsetComponent4.view.leftAnchor.constraint(equalTo: badgeSunriseComponent4.view.rightAnchor, constant: 30),
            badgeSunsetComponent4.view.rightAnchor.constraint(equalTo: badgesContainer.rightAnchor, constant: -30),
            badgeSunsetComponent4.view.topAnchor.constraint(equalTo: badgeWindComponent4.view.bottomAnchor, constant: 30),
            badgeSunsetComponent4.view.bottomAnchor.constraint(equalTo: badgesContainer.bottomAnchor),
            badgeSunsetComponent4.view.widthAnchor.constraint(lessThanOrEqualTo: badgesContainer.widthAnchor, multiplier: 0.5, constant: -30*1.5),
            
            badgesContainer.topAnchor.constraint(equalTo: centralContainer.bottomAnchor, constant: 50),
            badgesContainer.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            badgesContainer.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            
            calendarComponent.view.topAnchor.constraint(equalTo: badgesContainer.bottomAnchor, constant: 50),
            calendarComponent.view.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            calendarComponent.view.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            calendarComponent.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Scroll view
            
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: headContainer.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
        ])
    }
    
    private func updateContent(forCoordinate coordinate: CLLocationCoordinate2D) {
        momentumForecastSubscriber = {
            let forecastPublisher = forecastModel?.momentumForecast(forCoordinate: coordinate)
            
            let updationClosure: (WeatherData?) -> Void = { [weak self] (weatherData: WeatherData?) in
                self?.updateViewMomentumPublisher.send(weatherData)
            }
            updationClosure(forecastPublisher?.value)
            
            return forecastPublisher?.sink(
                receiveCompletion: { _ in },
                receiveValue: updationClosure
            )
        }()
        
        longTermForecastSubscriber = {
            let forecastPublisher = forecastModel?.longTermForecast(forCoordinate: coordinate)
            
            let updationClosure: ([WeatherData]?) -> Void = { [weak self] (weatherData: [WeatherData]?) in
//                print(weatherData == nil ? "254: nil" : "254: not nil")
                self?.updateViewLongTermPublisher.send(weatherData)
            }
            updationClosure(forecastPublisher?.value)
            
            return forecastPublisher?.sink(
                receiveCompletion: { _ in },
                receiveValue: updationClosure
            )
        }()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(centralContainer)
        scrollView.addSubview(badgesContainer)
        scrollView.addSubview(calendarComponent.view)
        
        view.addSubview(headContainer)
        view.addSubview(scrollView)
        
        activateConstraints()
        
        locationModel?.requestAppropriateAuthorization()
        
        locationSubscriber = locationModel?.updationPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] coordinate in
                if let coordinate {
                    self?.updateContent(forCoordinate: coordinate)
                }
            }
        )
    }
    
}
