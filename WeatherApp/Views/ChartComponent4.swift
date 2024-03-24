//
//  TemperatureChartComponent4.swift
//  WeatherApp
//
//  Created by Вадим Попов on 23.03.2024.
//

import UIKit
import Combine


private class ChartViewCell: UICollectionViewCell {
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 12)
        label.textColor = .white
        label.text = "––:––"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageComponentPublisher = CurrentValueSubject<WeatherData?, Error>(nil)
    let imageComponent: CentralImageComponent4
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 18)
        label.textColor = .white
        label.text = "––º"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        imageComponent = CentralImageComponent4(listen: imageComponentPublisher.eraseToAnyPublisher())
        
        super.init(frame: frame)
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(imageComponent.view)
        contentView.addSubview(temperatureLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            imageComponent.view.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            imageComponent.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageComponent.view.widthAnchor.constraint(equalToConstant: 30),
            imageComponent.view.heightAnchor.constraint(equalToConstant: 22),
            
            temperatureLabel.topAnchor.constraint(equalTo: imageComponent.view.bottomAnchor, constant: 20),
            temperatureLabel.centerXAnchor.constraint(equalTo: imageComponent.view.centerXAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setModel(model: WeatherData?) {
        imageComponentPublisher.send(model)
    }
    
}


private class ChartCollection: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var lastFetchedModel: [WeatherData] = []
    private var subscriber: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<[WeatherData]?, Error>, reloadDataClosure: @escaping () -> Void) {
        super.init()
        
        subscriber = modelPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] weatherDataList in
                self?.lastFetchedModel = weatherDataList ?? []
                reloadDataClosure()
            }
        )
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 54, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chartCollectionViewCell", for: indexPath) as! ChartViewCell
        
        guard indexPath.item < lastFetchedModel.count else { return cell }
        let modelItem = lastFetchedModel[indexPath.item]
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "HH:mm"
        let timeText = dateFormatter.string(from: modelItem.date)
        
        // Degrees
        let degreesText = "\(Int(modelItem.main.temperature.rounded()))°"
        
        // Cell
        cell.setModel(model: modelItem)
        cell.timeLabel.text = timeText
        cell.temperatureLabel.text = degreesText
        
        return cell
    }
    
}


private class ChartView: UIView {
    var model: [Int] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let barWidth = 54
        let lineWidth = 2
        
        let minValue = model.min() ?? 0
        let maxValue = model.max() ?? 1
        
        let points = model.enumerated().map { index, value in
            let height = abs((value - minValue) * (Int(rect.height) - lineWidth) / (maxValue - minValue))
            
            return CGPoint(
                x: index * barWidth + barWidth / 2,
                y: Int(rect.height) - lineWidth - height
            )
        }
        
        guard points.count > 1 else { return }
        
        context.setLineWidth(CGFloat(lineWidth))
        context.setStrokeColor(UIColor(red: 0.09375, green: 0.625, blue: 0.98046875, alpha: 1).cgColor)
        
        var previousPoint = points[0]
        context.move(to: CGPoint(x: previousPoint.x, y: previousPoint.y))
        
        for point in points.dropFirst() {
            let currentPoint = CGPoint(x: point.x, y: point.y)
            let controlPoint1 = CGPoint(x: (previousPoint.x + currentPoint.x) / 2, y: previousPoint.y)
            let controlPoint2 = CGPoint(x: (previousPoint.x + currentPoint.x) / 2, y: currentPoint.y)
            
            context.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
            previousPoint = point
        }
        
        context.strokePath()
    }
}


class ChartComponent4: Component4 {
    typealias Model = [WeatherData]?
    typealias ConcreteView = UIView
    
    var model: Model = nil
    var view: ConcreteView
    private let chartView = ChartView()
    
    private let collectionDelegate: ChartCollection
    private var modelSubscription: AnyCancellable? = nil
    
    init(listen modelPublisher: CurrentValueSubject<Model, Error>) {
        let badgeGrayColor = UIColor(red: 0.2578125, green: 0.2578125, blue: 0.30859375, alpha: 1)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Inter", size: 16)
        titleLabel.textColor = .white
        titleLabel.text = "24-hour forecast"
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = badgeGrayColor

        let currentDayDate = Self.currentDayDate()
        let dayModelPublisher = modelPublisher.map({ (weatherDataList: [WeatherData]?) in
            return weatherDataList?.filter { weatherData in weatherData.timestamp <= currentDayDate.timeIntervalSince1970 + 24 * 3600 }
        }).eraseToAnyPublisher()
        
        collectionDelegate = ChartCollection(listen: dayModelPublisher) { [weak collectionView] in
            DispatchQueue.main.async { [weak collectionView] in
                collectionView?.reloadData()
            }
        }
        
        collectionView.delegate = collectionDelegate
        collectionView.dataSource = collectionDelegate
        collectionView.register(ChartViewCell.self, forCellWithReuseIdentifier: "chartCollectionViewCell")
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = badgeGrayColor
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(collectionView)
        scrollView.addSubview(chartView)
        
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = badgeGrayColor
        view.layer.cornerRadius = 12
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            
            collectionView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 25),
            collectionView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100),
            collectionView.widthAnchor.constraint(equalToConstant: 54*7),
            
            chartView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            chartView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            chartView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            chartView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            chartView.heightAnchor.constraint(equalToConstant: 80),
            
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 25),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
        ])
        
        modelSubscription = dayModelPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] weatherDataList in
                self?.requestUpdates(withModel: weatherDataList)
            }
        )
    }
    
    func requestUpdates(withModel model: Model) {
        let chartData = model?.map { weatherData in
            Int(weatherData.main.temperature.rounded())
        } ?? []
        
        guard chartData.count > 0 else { return }
        
        chartView.model = chartData
    }
    
    private static func dayDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    private static func currentDayDate() -> Date {
        return Self.dayDate(.now)
    }
}
