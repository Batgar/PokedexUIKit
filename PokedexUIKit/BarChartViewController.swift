//
//  BarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Charts
import UIKit

class BarChartViewController: UIViewController {
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
    
    private lazy var chartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.delegate = self
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.maxVisibleCount = 60
        return barChartView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
       
        
        /*let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0*/
        
        updateChartData()
    }
    
    func updateChartData() {
        var alreadyIncludedHeight = false
        var valueColors: [UIColor] = []
        
        let yVals: [BarChartDataEntry] = allPokemon.compactMap {
            $0.heightM == nil ? nil : $0
        }.sorted(by: { $0.heightM! < $1.heightM! } ).enumerated().compactMap { index, pokemon in
            if let heightM = pokemon.heightM,
                heightM == selectedPokemon.heightM,
               !alreadyIncludedHeight {
                alreadyIncludedHeight = true
                valueColors.append(pokemon.color)
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
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 20
        chartView.data = data
    }
}

extension BarChartViewController: ChartViewDelegate {
    
}
