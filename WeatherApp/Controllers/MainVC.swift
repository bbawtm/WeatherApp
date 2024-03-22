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

// MARK: - Main View Controller

class MainVC: UIViewController {
    
    private weak var forecastModel = ForecastModel.instance
    private weak var locationModel = LocationModel.instance
    
    private var locationSubscriber: AnyCancellable?
    private var momentumForecastSubscriber: AnyCancellable?
    private var longTermForecastSubscriber: AnyCancellable?
    
    private let updateViewMomentumPublisher = CurrentValueSubject<WeatherData?, Error>(nil)
    private let updateViewLongTermPublisher = CurrentValueSubject<[WeatherData]?, Error>(nil)
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "cloud.fill")
        tabBarItem = UITabBarItem(
            title: "",
            image: icon?.withTintColor(.white, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1), renderingMode: .alwaysOriginal)
        )
        
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
            centralImageComponent4.view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            centralImageComponent4.view.heightAnchor.constraint(equalToConstant: 100),
            
            centralDegreesComponent4.view.topAnchor.constraint(equalTo: centralImageComponent4.view.bottomAnchor, constant: 10),
            centralDegreesComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralDescriptionComponent4.view.topAnchor.constraint(equalTo: centralDegreesComponent4.view.bottomAnchor),
            centralDescriptionComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralSubscriptComponent4.view.topAnchor.constraint(equalTo: centralDescriptionComponent4.view.bottomAnchor, constant: 5),
            centralSubscriptComponent4.view.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            centralSubscriptComponent4.view.bottomAnchor.constraint(equalTo: centralContainer.bottomAnchor),
            
            centralContainer.topAnchor.constraint(equalTo: headContainer.bottomAnchor, constant: 50),
            centralContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
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
        
        view.addSubview(headContainer)
        view.addSubview(centralContainer)
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
