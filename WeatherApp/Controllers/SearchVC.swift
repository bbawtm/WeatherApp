//
//  SearchVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit


class SearchVC: UIViewController {
    
    private weak var model = ForecastModel.instance
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "magnifyingglass")
        tabBarItem = UITabBarItem(
            title: "",
            image: icon?.withTintColor(.white, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1), renderingMode: .alwaysOriginal)
        )
        
        return self
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
    }
    
}
