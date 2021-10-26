//
//  AbilityChooserView.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/26/21.
//

import SwiftUI

struct AbilityChooserView: View {
    @State private var selection = Set<Ability>()
    
    @State private var editMode = EditMode.active
    
    let abilities: [Ability]
    let chooseAbilities: (([Ability]) -> Void)
    
    var body: some View {
        List(abilities, id: \.self, selection: $selection) {
            AbilitySelectorView(ability: $0)
        }
        .environment(\.editMode, $editMode)
        .navigationTitle("Filter for Abilities")
        .navigationBarItems(
            trailing: HStack {
                Button("Apply") {
                    chooseAbilities(Array(selection))
                }
            }
        )
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct AbilitySelectorView: View {
    let ability: Ability
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text("\(ability.ability) - \(ability.pokemon.count)")
                    .minimumScaleFactor(0.4)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 55,
                        alignment: .leading
                    )
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 20), spacing: 2)
                ]) {
                    ForEach(ability.uniqueTypes) {
                        Image(uiImage: $0.smallestImage!)
                            .padding(0)
                    }
                }
            }
        }
    }
}

struct AbilityChooserView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityChooserView(
            abilities: Pokemon.previewPikachu.abilities.map {
                Ability(
                    pokemon: [
                        Pokemon.previewPikachu,
                        Pokemon.previewStunfisk
                    ],
                    ability: $0
                )
            },
            chooseAbilities: { _ in }
        )
    }
}
