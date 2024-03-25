//
//  SearchVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit
import MapKit


class SearchVC: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    private weak var model = ForecastModel.instance
    private let locationModel = SearchLocationModel()
    
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.delegate = self
        
        return searchBar
    }()
    
    private let scrollView = UIScrollView()
    
    private let mapLabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "The found location:"
        lbl.font = UIFont(name: "Inter", size: 16)
        lbl.textColor = .white
        return lbl
    }()
    
    private let mapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 12
        return mapView
    }()
    
    private lazy var mapViewContainer = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.2578125, green: 0.2578125, blue: 0.30859375, alpha: 1)
        container.layer.cornerRadius = 12
        container.addSubview(mapView)
        return container
    }()
    
    private lazy var locationDescriptionComponent4 = HeadLocationDescriptionComponent4(locationModel: locationModel)
    
    private lazy var dailySummaryVC = {
        let mainVC = MainVC()
        mainVC.locationModel = locationModel
        mainVC.view.translatesAutoresizingMaskIntoConstraints = false
        return mainVC
    }()
    
    private lazy var dailySummaryView = {
        dailySummaryVC.scrollView.contentLayoutGuide.owningView ?? UIView()
    }()
    
    private lazy var dailySummaryContainer = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "magnifyingglass")
        let colorSelected = UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1)
        let colorNonSelected = UIColor.white
        
        tabBarItem = UITabBarItem(
            title: "Search",
            image: icon?.withTintColor(colorNonSelected, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(colorSelected, renderingMode: .alwaysOriginal)
        )
        
        UITabBar.appearance().tintColor = colorSelected
        UITabBar.appearance().unselectedItemTintColor = colorNonSelected
        
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        navigationItem.titleView = searchBar
        mapView.delegate = self
        
        addChild(dailySummaryVC)
        dailySummaryContainer.addSubview(dailySummaryView)
        dailySummaryVC.didMove(toParent: self)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mapLabel)
        scrollView.addSubview(mapViewContainer)
        scrollView.addSubview(locationDescriptionComponent4.view)
        scrollView.addSubview(dailySummaryContainer)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            mapLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 25),
            mapLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 18),
            mapLabel.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -18),
            
            mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor),
            mapView.leftAnchor.constraint(equalTo: mapViewContainer.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: mapViewContainer.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor),
            
            mapViewContainer.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 20),
            mapViewContainer.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 18),
            mapViewContainer.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -18),
            mapViewContainer.heightAnchor.constraint(equalToConstant: 250),
            
            locationDescriptionComponent4.view.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor, constant: 15),
            locationDescriptionComponent4.view.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 18),
            
            dailySummaryView.topAnchor.constraint(equalTo: dailySummaryContainer.topAnchor),
            dailySummaryView.bottomAnchor.constraint(equalTo: dailySummaryContainer.bottomAnchor),
            dailySummaryView.leftAnchor.constraint(equalTo: dailySummaryContainer.leftAnchor),
            dailySummaryView.rightAnchor.constraint(equalTo: dailySummaryContainer.rightAnchor),
            
            dailySummaryContainer.topAnchor.constraint(equalTo: locationDescriptionComponent4.view.bottomAnchor, constant: 20),
            dailySummaryContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            dailySummaryContainer.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            dailySummaryContainer.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            dailySummaryContainer.heightAnchor.constraint(equalTo: dailySummaryVC.scrollView.contentLayoutGuide.heightAnchor),
            
            scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        dailySummaryContainer.isHidden = true
        scrollView.isScrollEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text

        let localSearch = MKLocalSearch(request: request)
        localSearch.start { [weak self] response, error in
            guard let response = response, error == nil else {
                return
            }

            if let mapItem = response.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                
                self?.locationModel.publisher.send(mapItem.placemark.location)
                self?.mapLocateItem(coordinate: coordinate)
                
                self?.dailySummaryContainer.isHidden = self?.locationModel.publisher.value == nil
                self?.scrollView.isScrollEnabled = self?.locationModel.publisher.value != nil
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func mapLocateItem(coordinate: CLLocationCoordinate2D) {
        var region = MKCoordinateRegion()
        region.center = coordinate
        region.span.latitudeDelta = 0.1
        region.span.longitudeDelta = 0.1
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView()
        annotationView.annotation = annotation
        return annotationView
    }
    
}
