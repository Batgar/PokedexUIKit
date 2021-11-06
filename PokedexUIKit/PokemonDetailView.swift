//
//  PokemonSwiftUIDetailViewController.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/31/21.
//

import Charts
import SwiftUI

struct PokemonDetailView: View {
    let allPokemon: [Pokemon]
    @State var selectedPokemon: Pokemon
    
    var body: some View {
        GeometryReader { metrics in
            let baseHeight =  metrics.size.height * 0.5
            LazyHGrid(
                rows: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ]
            ) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ]) {
                    PokemonCardView(selectedPokemon: $selectedPokemon)
                        .frame(minHeight: baseHeight)
                        .padding()
                    
                    WeakestAgainstPieChartView(selectedPokemon: $selectedPokemon)
                        .frame(minHeight: baseHeight)
                        .padding()
                    
                }.frame(minWidth: metrics.size.width,
                        minHeight: baseHeight)
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                ]) {
                    HStack {
                        GraphBarView(
                            height: selectedPokemon.hp / allPokemon.maxHP,
                            color: Color(selectedPokemon.type1.color),
                            label: "HP",
                            value: "\(Int(selectedPokemon.hp))"
                        )
                        
                        GraphBarView(
                            height: selectedPokemon.attack / allPokemon.maxAttack,
                            color: Color(selectedPokemon.type1.color),
                            label: "Attack",
                            value: "\(Int(selectedPokemon.attack))"
                        )
                        
                        GraphBarView(
                            height: selectedPokemon.defense / allPokemon.maxDefense,
                            color: Color(selectedPokemon.type1.color),
                            label: "Defense",
                            value: "\(Int(selectedPokemon.defense))"
                        )
                        
                        GraphBarView(
                            height: selectedPokemon.spAttack / allPokemon.maxSpecialAttack,
                            color: Color(selectedPokemon.type1.color),
                            label: "Special Attack",
                            value: "\(Int(selectedPokemon.spAttack))"
                        )
                        
                        GraphBarView(
                            height: selectedPokemon.spDefense / allPokemon.maxSpecialDefense,
                            color: Color(selectedPokemon.type1.color),
                            label: "Special Defense",
                            value: "\(Int(selectedPokemon.spDefense))"
                        )
                        
                        GraphBarView(
                            height: selectedPokemon.speed / allPokemon.maxSpeed,
                            color: Color(selectedPokemon.type1.color),
                            label: "Speed",
                            value: "\(Int(selectedPokemon.speed))"
                        )
                    }.frame(minHeight: baseHeight)
                }.frame(minWidth: metrics.size.width,
                         minHeight: metrics.size.height * 0.5)
            }.frame(minWidth: metrics.size.width, minHeight: metrics.size.height)
        }
    }
}

struct GraphBarView: View {
    let height: CGFloat
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        GeometryReader { metrics in
            let barHeight = (metrics.size.height - 24) * 0.8
            let labelHeight = (metrics.size.height - 16) * 0.2
            
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color)
                    .frame(
                        width: 20,
                        height: barHeight * height
                    )
                VStack(spacing: 0) {
                    Spacer()
                    Text(label)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                    Text(value)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                }
                .frame(height: labelHeight)
            }
            .frame(width: metrics.size.width)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
    }
}

struct PokemonCardView: UIViewRepresentable {
    @Binding var selectedPokemon: Pokemon

    func makeUIView(context: Context) -> PokemonView {
        PokemonView()
    }

    func updateUIView(_ uiView: PokemonView, context: Context) {
        
        uiView.nameLabel.text = selectedPokemon.name
        uiView.pokedexNumberLabel.text = "#\(selectedPokemon.pokedexNumber)"
        uiView.stackBackgroundView.backgroundColor = selectedPokemon.type1.color.withAlphaComponent(0.2)
        uiView.imageView.kf.setImage(
            with: selectedPokemon.imageURL,
            placeholder: UIImage(named: "International_Pokemon_logo")
        )
        uiView.type1ImageView.image = selectedPokemon.type1.image
        uiView.type2ImageView.image = selectedPokemon.type2?.image
        uiView.stackBackgroundView.backgroundColor = selectedPokemon.type1.color.withAlphaComponent(0.2)
    }
}

struct WeakestAgainstPieChartView: UIViewRepresentable {
    @Binding var selectedPokemon: Pokemon

    func makeUIView(context: Context) -> PieChartView {
        let pieChartView = PieChartView()
        pieChartView.legend.enabled = false
        pieChartView.centerAttributedText = NSAttributedString(string: "Weakest Against")
        return pieChartView
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        updatePieChartData(pieChartView: uiView)
    }
    
    private func updatePieChartData(pieChartView: PieChartView) {
        let defenseSummaries = selectedPokemon.defenseSummaries.sorted(by: { $0.value > $1.value })
        
        let entries: [PieChartDataEntry] = defenseSummaries.map {
            // IMPORTANT: In a PieChart, no values (Entry) should have the same
            // xIndex (even if from different DataSets), since no values can be
            // drawn above each other.
            PieChartDataEntry(
                value: $0.value,
                label: $0.type.title,
                icon: $0.type.smallerImage
            )
        }
        
        let set = PieChartDataSet(entries: entries, label: "Attack Effectiveness")
        set.drawIconsEnabled = true
        set.drawValuesEnabled = false
        set.iconsOffset = CGPoint(x: 0, y: 60)
        set.sliceSpace = 2
        set.colors = defenseSummaries.compactMap { $0.type.color }
        
        let data = PieChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        pieChartView.data = data
        pieChartView.highlightValues(nil)
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(
            allPokemon: [
                Pokemon.previewPikachu,
                Pokemon.previewStunfisk,
            ],
            selectedPokemon: Pokemon.previewPikachu
        )
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}

private extension Array where Element == Pokemon {
    var maxHP: Double {
        self.max(by: { a, b in a.hp < b.hp })?.hp ?? 0
    }
    
    var maxAttack: Double {
        self.max(by: { a, b in a.attack < b.attack })?.attack ?? 0
    }
    
    var maxDefense: Double {
        self.max(by: { a, b in a.defense < b.defense })?.defense ?? 0
    }
    
    var maxSpecialAttack: Double {
        self.max(by: { a, b in a.spAttack < b.spAttack })?.spAttack ?? 0
    }
    
    var maxSpecialDefense: Double {
        self.max(by: { a, b in a.spDefense < b.spDefense })?.spDefense ?? 0
    }
    
    var maxSpeed: Double {
        self.max(by: { a, b in a.speed < b.speed })?.speed ?? 0
    }
}
