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
    
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.delegate = self
        
        return searchBar
    }()
    
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
        let mapViewContainer = UIView()
        mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        mapViewContainer.backgroundColor = UIColor(red: 0.2578125, green: 0.2578125, blue: 0.30859375, alpha: 1)
        mapViewContainer.layer.cornerRadius = 12
        mapViewContainer.addSubview(mapView)
        return mapViewContainer
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
        
        view.addSubview(mapLabel)
        view.addSubview(mapViewContainer)
        
        NSLayoutConstraint.activate([
            mapLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            mapLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 18),
            mapLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -18),
            
            mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor),
            mapView.leftAnchor.constraint(equalTo: mapViewContainer.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: mapViewContainer.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor),
            
            mapViewContainer.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 20),
            mapViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 18),
            mapViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -18),
            mapViewContainer.heightAnchor.constraint(equalToConstant: 250),
        ])
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
//                let lm = LocationModel.requestLocationRepresentation(mapItem.placemark.location) { repr in
//                    print(repr)
//                }
                self?.mapLocateItem(coordinate: coordinate)
            }
        }
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
