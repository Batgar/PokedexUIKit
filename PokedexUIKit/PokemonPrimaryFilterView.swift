//
//  PokemonPrimaryFilterView.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/24/21.
//

import SwiftUI

struct PokemonPrimaryFilterView: View {
    var choosePokemonType: ((Pokemon.PokemonType) -> Void)!
    var chooseAllPokemon: (() -> Void)!
    
    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
    ]
    
    var body: some View {
        ScrollView {
            HStack
            {
                Text("All Pokémon")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 55
                    )
                    
            }
            .background(Color.blue)
            .cornerRadius(12)
            .padding()
            .onTapGesture {
                chooseAllPokemon()
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Pokemon.PokemonType.allCases.sorted(by: {$0.rawValue < $1.rawValue }), id: \.self) { pokemonType in
                    PokemonTypeChooserView(
                        pokemonType: pokemonType
                    ).onTapGesture {
                        choosePokemonTypeTapGesture(pokemonType)
                    }
                }
            }
            .padding()
        }
    }
    
    func choosePokemonTypeTapGesture(
        _ pokemonType: Pokemon.PokemonType
    ) {
        self.choosePokemonType(pokemonType)
    }
}

struct PokemonTypeChooserView: View {
    let pokemonType: Pokemon.PokemonType
    var body: some View {
        HStack
        {
            Image(uiImage: pokemonType.smallerImage!)
                .padding(4)
            Text(pokemonType.title)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.title)
                .padding(4)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 55,
                    alignment: .leading)
                
        }
        .background(Color(pokemonType.color))
        .cornerRadius(12)
    }
}

struct PokemonPrimaryFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonPrimaryFilterView()
    }
}
