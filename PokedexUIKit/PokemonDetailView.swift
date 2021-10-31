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
            LazyHGrid(
                rows: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                ]
            ) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                ]) {
                    PokemonCardView(selectedPokemon: $selectedPokemon)
                        .frame(minHeight: metrics.size.height * 0.5)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(minHeight: metrics.size.height * 0.5)
                }.frame(minWidth: metrics.size.width,
                        minHeight: metrics.size.height * 0.5)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                ]) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(minHeight: metrics.size.height * 0.5)
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(minHeight: metrics.size.height * 0.5)
                }.frame(minWidth: metrics.size.width,
                         minHeight: metrics.size.height * 0.5)
            }.frame(minWidth: metrics.size.width, minHeight: metrics.size.height)
        }.background(.cyan)
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
    }
}
