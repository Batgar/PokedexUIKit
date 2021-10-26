//
//  PokemonPrimaryFilterView.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/24/21.
//

import SFSafeSymbols
import SwiftUI

struct PokemonPrimaryFilterView: View {
    let allAbilities: [Ability]
    
    var choosePokemonType: ((Pokemon.PokemonType) -> Void)!
    var chooseAllPokemon: (() -> Void)!
    var chooseAbilities: (([Ability]) -> Void)!
    
    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Button(action: {
                        chooseAllPokemon()
                    }) {
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
                    }
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Pokemon.PokemonType.allCases.sorted(by: {$0.rawValue < $1.rawValue }), id: \.self) { pokemonType in
                            Button(action: {
                                choosePokemonTypeTapGesture(pokemonType)
                            }) {
                                PokemonTypeChooserView(
                                    pokemonType: pokemonType
                                )
                            }
                        }
                    }
                    .padding()
                }
                Divider()
                NavigationLink(
                    destination: AbilityChooserView(
                        abilities: allAbilities,
                        chooseAbilities: chooseAbilities
                    )
                ) {
                    HStack {
                        Image(systemSymbol: .figureWalkCircle)
                            .imageScale(.large)
                            .padding(4)
                        Text("Abilities")
                            .font(.title)
                            .padding(4)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 55,
                                alignment: .leading
                            )
                    }
                    .padding(8)
                }
                Divider()
            }
            .navigationTitle("Filter")
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
        PokemonPrimaryFilterView(
            allAbilities: Pokemon.previewPikachu.abilities.map {
                Ability(
                    pokemon: [
                        Pokemon.previewPikachu
                    ],
                    ability: $0
                )
            }
        )
    }
}
