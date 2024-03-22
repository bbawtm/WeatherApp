//
//  MainVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit
import CoreLocation
import Combine


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

// MARK: - Head Container Items

private class HeadDayDescriptionComponent4: Component4 {
    typealias Model = Any?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let lbl = UILabel()
        lbl.text = "Today, \(dateFormatter.string(from: Date.now))"
        lbl.font = UIFont(name: "Inter", size: 17)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
    }
    
    func requestUpdates(withModel model: Model) {
    }
}

private class HeadLocationDescriptionComponent4: Component4 {
    typealias Model = Any?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private weak var locationModel = LocationModel.instance
    private var modelSubscribtion: AnyCancellable?
    
    init() {
        let lbl = UILabel()
        
        lbl.textAlignment = .center
        lbl.attributedText = Self.locationLabelAttributedText(string: "Updating...")
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = locationModel?.updationPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] _ in
                self?.requestUpdates(withModel: nil)
            }
        )
    }
    
    func requestUpdates(withModel model: Model) {
        locationModel?.requestCurrentLocationRepresentation { [weak self] representation in
            guard let self else { return }
            self.view.attributedText = Self.locationLabelAttributedText(string: representation)
        }
    }
    
    private static func locationLabelAttributedText(string: String) -> NSAttributedString {
        let completeText = NSMutableAttributedString(string: "")
        
        if let mapPinImage = UIImage(named: "map.pin") {
            completeText.append(NSAttributedString(attachment: NSTextAttachment(image: mapPinImage)))
            completeText.append(NSAttributedString(string: " "))
        }
        
        let locationDescription = NSAttributedString(string: string)
        completeText.append(locationDescription)
        
        return completeText
    }
}

// MARK: - Central Container Items

private class CentralImageComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UIImageView
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let image = UIImage(named: "cloud.sun")
        
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        view = imgView
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.image = UIImage(named: "cloud.sun")
                self.view.contentMode = .scaleAspectFill
                return
            }
            
            switch weatherData.weather.code {
            case .thunderstorm:
                self.view.image = UIImage(named: "thunder")
                self.view.contentMode = .scaleAspectFit
                
            case .drizzle:
                self.view.image = UIImage(named: "rain")
                self.view.contentMode = .scaleAspectFit
                
            case .rain:
                self.view.image = UIImage(named: "rain")
                self.view.contentMode = .scaleAspectFit
                
            case .snow:
                self.view.image = UIImage(named: "rain")
                self.view.contentMode = .scaleAspectFit
                
            case .atmosphere:
                self.view.image = UIImage(named: "atmosphere")
                
            case .clear:
                self.view.image = UIImage(named: "sun")
                self.view.contentMode = .scaleAspectFit
                
            case .clouds:
                self.view.image = UIImage(named: "cloud.sunny")
            }
        }
    }
}

private class CentralDegreesComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "––º"
        lbl.font = UIFont(name: "Inter", size: 70)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "––º"
                return
            }
            
            self.view.text = "\(Int(weatherData.main.temperature.rounded()))º"
        }
    }
}

private class CentralDescriptionComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "Unknown weather"
        lbl.font = UIFont(name: "Inter", size: 18)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "Unknown weather"
                return
            }
            
            self.view.text = weatherData.weather.title
        }
    }
}

private class CentralSubscriptComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "Trying to update information..."
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "Couldn't get the information"
                return
            }
            
            self.view.text = weatherData.weather.description.capitalizingFirstLetter()
        }
    }
}

// MARK: - Badges

private class BadgeItemComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UIView
    
    var model: Model = nil
    var view: ConcreteView
    private var valueLabel: UILabel
    
    private var defaultValue: String
    private var valueGetter: (Model) -> String
    private var modelSubscribtion: AnyCancellable?
    
    init(
        imageName: String,
        titleText: String,
        defaultValue: String,
        valueGetter: @escaping (Model) -> String,
        listen modelPublisher: AnyPublisher<Model, Error>
    ) {
        self.defaultValue = defaultValue
        self.valueGetter = valueGetter
        
        let icon = UIImageView(image: UIImage(named: imageName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = titleText
        title.font = UIFont(name: "Inter", size: 16)
        title.textColor = .white
        
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(icon)
        titleContainer.addSubview(title)
        
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = defaultValue
        valueLabel.font = UIFont(name: "Inter", size: 14)
        valueLabel.textColor = .white
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(titleContainer)
        content.addSubview(valueLabel)
        
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = UIColor(red: 0.2578125, green: 0.2578125, blue: 0.30859375, alpha: 1)
        badge.layer.cornerRadius = 12
        badge.addSubview(content)
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor, constant: -2),
            icon.leftAnchor.constraint(equalTo: titleContainer.leftAnchor),
            
            title.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10),
            title.rightAnchor.constraint(equalTo: titleContainer.rightAnchor),
            
            titleContainer.topAnchor.constraint(equalTo: content.topAnchor),
            titleContainer.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20),
            valueLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            
            content.topAnchor.constraint(equalTo: badge.topAnchor, constant: 30),
            content.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -22),
            content.leftAnchor.constraint(equalTo: badge.leftAnchor, constant: 22),
            content.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -20),
        ])
        
        view = badge
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.valueLabel.text = self.valueGetter(model)
        }
    }
}

// MARK: - Main View Controller

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
            
            centralContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
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
            
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: headContainer.bottomAnchor, constant: 50),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
        ])
    }
    
    private func updateContent(forCoordinate coordinate: CLLocationCoordinate2D) {
        let momentumForecastPublisher = forecastModel?.momentumForecast(forCoordinate: coordinate)
        
        let momentumForecastUpdationClosure: (WeatherData?) -> Void = { [weak self] (weatherData: WeatherData?) in
            self?.updateViewMomentumPublisher.send(weatherData)
        }
        momentumForecastUpdationClosure(momentumForecastPublisher?.value)
        
        momentumForecastSubscriber = momentumForecastPublisher?.sink(
            receiveCompletion: { _ in },
            receiveValue: momentumForecastUpdationClosure
        )
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(centralContainer)
        scrollView.addSubview(badgesContainer)
        
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
