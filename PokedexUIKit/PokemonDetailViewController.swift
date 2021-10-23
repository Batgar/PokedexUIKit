//
//  BarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Charts
import UIKit

class PokemonDetailViewController: UIViewController {
    let allPokemon: [Pokemon]
    let selectedPokemon: Pokemon
    
    init(
        allPokemon: [Pokemon],
        selectedPokemon: Pokemon
    ) {
        self.allPokemon = allPokemon
        self.selectedPokemon = selectedPokemon
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var heightChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.drawGridBackgroundEnabled = false
        barChartView.delegate = self
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.xAxis.enabled = false
        barChartView.legend.enabled = false
        return barChartView
    }()
    
    private lazy var attackChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.drawGridBackgroundEnabled = false
        barChartView.delegate = self
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.xAxis.enabled = false
        barChartView.legend.enabled = false
        return barChartView
    }()
    
    private lazy var weightChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.drawGridBackgroundEnabled = false
        barChartView.delegate = self
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.xAxis.enabled = false
        barChartView.legend.enabled = false
        return barChartView
    }()
    
    private lazy var barChartStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            attackChartView,
            heightChartView,
            weightChartView,
        ])
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            barChartStackView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            attackChartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            weightChartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            heightChartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
        ])
        
        updateChartData()
    }
    
    func updateChartData() {
        updateAttackChartData()
        updateHeightChartData()
        updateWeightChartData()
    }
    
    func updateHeightChartData() {
        guard
            selectedPokemon.heightM != nil
        else {
            heightChartView.isHidden = true
            return
        }
        
        var alreadyIncludedHeight = false
        var valueColors: [UIColor] = []
        
        let yVals: [BarChartDataEntry] = allPokemon.compactMap {
            $0.heightM == nil ? nil : $0
        }.sorted(by: { $0.heightM! < $1.heightM! } )
            .enumerated()
            .compactMap { index, pokemon in
                if let heightM = pokemon.heightM,
                   heightM == selectedPokemon.heightM,
                   !alreadyIncludedHeight {
                    alreadyIncludedHeight = true
                    valueColors.append(selectedPokemon.color)
                    return BarChartDataEntry(x: Double(index), y: heightM, icon: selectedPokemon.type1.smallImage)
                } else if index % 20 == 0 {
                    valueColors.append(pokemon.color)
                    return BarChartDataEntry(x: Double(index), y: pokemon.heightM!)
                } else {
                    return nil
                }
            }
        
        let set1 = BarChartDataSet(entries: yVals, label: "All Pokemon Heights")
        set1.colors = valueColors
        set1.drawIconsEnabled = true
        set1.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.barWidth = 5
        
        heightChartView.isHidden = false
        heightChartView.data = data
    }
    
    func updateAttackChartData() {
        var alreadyIncludedHeight = false
        var valueColors: [UIColor] = []
        
        let yVals: [BarChartDataEntry] = allPokemon.sorted(by: { $0.attack < $1.attack } )
            .enumerated()
            .compactMap { index, pokemon in
                if !alreadyIncludedHeight {
                    alreadyIncludedHeight = true
                    valueColors.append(selectedPokemon.color)
                    return BarChartDataEntry(x: Double(index), y: pokemon.attack, icon: selectedPokemon.type1.smallImage)
                } else if index % 20 == 0 {
                    valueColors.append(pokemon.color)
                    return BarChartDataEntry(x: Double(index), y: pokemon.attack)
                } else {
                    return nil
                }
            }
        
        let set1 = BarChartDataSet(entries: yVals, label: "All Pokemon Heights")
        set1.colors = valueColors
        set1.drawIconsEnabled = true
        set1.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.barWidth = 5
        
        attackChartView.data = data
    }
    
    func updateWeightChartData() {
        guard
            selectedPokemon.weightKg != nil
        else {
            weightChartView.isHidden = true
            return
        }
        
        var alreadyIncludedHeight = false
        var valueColors: [UIColor] = []
        
        let yVals: [BarChartDataEntry] = allPokemon.compactMap {
            $0.weightKg == nil ? nil : $0
        }.sorted(by: { $0.weightKg! < $1.weightKg! } )
            .enumerated()
            .compactMap { index, pokemon in
                if let weightKg = pokemon.weightKg,
                   weightKg == selectedPokemon.weightKg,
                   !alreadyIncludedHeight {
                    alreadyIncludedHeight = true
                    valueColors.append(selectedPokemon.color)
                    return BarChartDataEntry(x: Double(index), y: weightKg, icon: selectedPokemon.type1.smallImage)
                } else if index % 20 == 0 {
                    valueColors.append(pokemon.color)
                    return BarChartDataEntry(x: Double(index), y: pokemon.weightKg!)
                } else {
                    return nil
                }
            }
        
        let set1 = BarChartDataSet(entries: yVals, label: "All Pokemon Heights")
        set1.colors = valueColors
        set1.drawIconsEnabled = true
        set1.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.barWidth = 5
        
        
        weightChartView.isHidden = false
        weightChartView.data = data
    }
}

extension PokemonDetailViewController: ChartViewDelegate {
    
}
