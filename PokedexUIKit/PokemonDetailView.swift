//
//  PokemonSwiftUIDetailViewController.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/31/21.
//

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
        }
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
