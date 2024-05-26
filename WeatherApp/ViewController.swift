//
//  ViewController.swift
//  WeatherApp
//
//  Created by Denis Raiko on 8.05.24.
//

import UIKit

class ViewController: UIViewController {
    
    var weatherDailyData: [DailyWeather] = []
    var weatherHourlyData: [HourlyWeather] = []
    
    static let shared = ViewController()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        return label
    }()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica Neue Bold", size: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [conditionLabel,
                                                  image,
                                                  temperatureLabel
                                                 ])
        view.axis = .vertical
        view.spacing = 18
        view.alignment = .center
        view.distribution = .equalSpacing
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerOfHourlyForecastCollectionView: UILabel = {
        let label = UILabel()
        label.text = "Hourly forecast"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var hourlyForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 130)
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 16
        collectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HourlyForecastCollectionViewCell.self, forCellWithReuseIdentifier: "HourlyForecastCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var headerOfDailyForecastCollectionView: UILabel = {
        let label = UILabel()
        label.text = "Daily forecast"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["3d", "5d"])
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentControl.selectedSegmentTintColor = .customCyanColor
        segmentControl.selectedSegmentIndex = 0
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(_:)), for: .valueChanged)
        return segmentControl
    }()
    
    private lazy var dailyForecastCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 16
        collectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DailyForecastCollectionViewCell.self, forCellWithReuseIdentifier: "DailyForecastCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conditionLabel.text = "Partly cloudy".localize()
        headerOfHourlyForecastCollectionView.text = "Hourly forecast".localize()
        headerOfDailyForecastCollectionView.text = "Daily forecast".localize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient(colors: [UIColor.customCyanColor, UIColor.systemCyan])
        setUpNavigationController(locationLabel: locationLabel.text ?? "")
        addSubViews()
        setupConstraints()
        
        sendCurrentRequestToServer()
        sendHourlyRequestToServer(forNumberOfDays: 1)
        if segmentControl.selectedSegmentIndex == 0 {
            sendDailyRequestToServer(forNumberOfDays: 3)
        } else {
            sendDailyRequestToServer(forNumberOfDays: 5)
        }
        
    }
    
    @objc private func segmentControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sendDailyRequestToServer(forNumberOfDays: 3)
        } else {
            sendDailyRequestToServer(forNumberOfDays: 5)
        }
    }
    
    private func setUpNavigationController(locationLabel: String) {
        navigationItem.title = locationLabel
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                         style: .done,
                                         target: self,
                                         action: #selector(reload))
        
        navigationItem.rightBarButtonItem = plusButton
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @objc private func reload() {
        
    }
    
    private func addSubViews() {
        view.addSubview(stackView)
        view.addSubview(headerOfHourlyForecastCollectionView)
        view.addSubview(hourlyForecastCollectionView)
        view.addSubview(headerOfDailyForecastCollectionView)
        view.addSubview(segmentControl)
        view.addSubview(dailyForecastCollectionView)
    }
    
    private func setupConstraints() {
        image.widthAnchor.constraint(equalToConstant: 90).isActive = true
        image.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        headerOfHourlyForecastCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10).isActive = true
        headerOfHourlyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        headerOfHourlyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        hourlyForecastCollectionView.topAnchor.constraint(equalTo: headerOfHourlyForecastCollectionView.bottomAnchor, constant: 10).isActive = true
        hourlyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        hourlyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        hourlyForecastCollectionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        headerOfDailyForecastCollectionView.bottomAnchor.constraint(equalTo: dailyForecastCollectionView.topAnchor, constant: -10).isActive = true
        headerOfDailyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        segmentControl.topAnchor.constraint(equalTo: hourlyForecastCollectionView.bottomAnchor, constant: 10).isActive = true
        segmentControl.leadingAnchor.constraint(equalTo: headerOfDailyForecastCollectionView.trailingAnchor, constant: 20).isActive = true
        segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        dailyForecastCollectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        dailyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        dailyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        dailyForecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    private func sendCurrentRequestToServer() {
        let api = CurrentAPI()
        api.sendRequest(locationLabel: locationLabel, tempLabel: temperatureLabel, conditionLabel: conditionLabel, icon: image) { [weak self] title in
            self?.navigationItem.title = title
        }
    }
    
    
    private func sendHourlyRequestToServer(forNumberOfDays numberOfDays: Int) {
        let api = HourlyAPI()
        api.sendRequest(forNumberOfDays: numberOfDays) { [weak self] (response) in
            guard !response.isEmpty else {
                // Обработка ошибки, если response пустой
                return
            }
            self?.weatherHourlyData = response // Присваивание данных из API
            DispatchQueue.main.async {
                self?.hourlyForecastCollectionView.reloadData()
            }
        }
    }
    
    private func sendDailyRequestToServer(forNumberOfDays numberOfDays: Int) {
        let api = DailyAPI()
        api.sendRequest(forNumberOfDays: numberOfDays) { [weak self] (response) in
            guard !response.isEmpty else {
                // Обработка ошибки, если response пустой
                return
            }
            self?.weatherDailyData = response // Присваивание данных из API
            DispatchQueue.main.async {
                self?.dailyForecastCollectionView.reloadData()
            }
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hourlyForecastCollectionView {
            return weatherHourlyData.count
        } else if collectionView == dailyForecastCollectionView {
            return weatherDailyData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hourlyForecastCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCollectionViewCell", for: indexPath) as? HourlyForecastCollectionViewCell else {
                return UICollectionViewCell()
            }
            let hourlyData = weatherHourlyData[indexPath.row]
            let imageUrlString = hourlyData.image
            guard let imageUrl = URL(string: "https:\(imageUrlString)") else {
                return UICollectionViewCell()
            }
            cell.configure(with: imageUrl, data: hourlyData)
            return cell
        }
        if collectionView == dailyForecastCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyForecastCollectionViewCell", for: indexPath) as? DailyForecastCollectionViewCell else {
                return UICollectionViewCell()
            }
            let dailyData = weatherDailyData[indexPath.row]
            let imageUrlString = dailyData.image
            guard let imageUrl = URL(string: "https:\(imageUrlString)") else {
                return UICollectionViewCell()
            }
            cell.configure(with: imageUrl, data: dailyData)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

