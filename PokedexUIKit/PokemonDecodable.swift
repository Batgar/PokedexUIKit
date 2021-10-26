//
//  PokemonDecodable.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import Combine
import Kingfisher
import Foundation
import UIKit

struct Pokemon: Decodable, Hashable {
    
    enum PokemonType: String, Decodable, CaseIterable, Hashable, Identifiable {
        var id: Self {
            self
        }
        
        case fire
        case flying
        case grass
        case poison
        case steel
        case dark
        case dragon
        case psychic
        case fairy
        case electric
        case water
        case ghost
        case rock
        case bug
        case fighting
        case ground
        case normal
        case ice
    }
    
    let abilities: [String]
    
    let againstBug: Double
    let againstDark: Double
    let againstDragon: Double
    let againstElectric: Double
    let againstFairy: Double
    let againstFight: Double
    let againstFire: Double
    let againstFlying: Double
    let againstGhost: Double
    let againstGrass: Double
    let againstGround: Double
    let againstIce: Double
    let againstNormal: Double
    let againstPoison: Double
    let againstPsychic: Double
    let againstRock: Double
    let againstSteel: Double
    let againstWater: Double
   
    let attack: Double
    var heightM: Double?
    let hp: Double
    let name: String
    let pokedexNumber: Int
    let type1: PokemonType
    var type2: PokemonType?
    var weightKg: Double?
    
    var imageURL: URL? {
        URL(string: "https://d1l90ic7yquy2f.cloudfront.net/\(pokedexNumber)-1024.png")
    }
}

struct Ability: Comparable, Hashable {
    static func < (lhs: Ability, rhs: Ability) -> Bool {
        lhs.ability < rhs.ability
    }
    
    let pokemon: [Pokemon]
    let ability: String
}

extension Pokemon {
    static func pokemonOfType(type: Pokemon.PokemonType) -> AnyPublisher<[Pokemon], Error> {
        decodeAllPokemon()
            .tryMap { allPokemon in
                allPokemon.filter { $0.type1 == type || $0.type2 == type }
            }
            .eraseToAnyPublisher()
    }
    
    static func pokemonWithAbility(_ ability: String) -> AnyPublisher<[Pokemon], Error> {
        decodeAllPokemon()
            .tryMap { allPokemon in
                allPokemon.filter { $0.abilities.contains(where: { $0 == ability }) }
            }
            .eraseToAnyPublisher()
    }
    
    static func decodeAllAbilities() -> AnyPublisher<[Ability], Error> {
        decodeAllPokemon()
            .tryMap { allPokemon in
                // First get all unique ability strings.
                let uniqueAbilities = Set<String>(allPokemon.flatMap { $0.abilities })
                
                return uniqueAbilities
                    .map { ability in
                        let allPokemonWithAbility = allPokemon.filter { $0.abilities.contains(ability) }
                        return Ability(pokemon: allPokemonWithAbility, ability: ability)
                    }.sorted(by: {
                        $0.ability < $1.ability
                    })
            }
            .eraseToAnyPublisher()
    }
    
    static func decodeAllPokemon() -> AnyPublisher<[Pokemon], Error> {
        guard
            let fileURL = Bundle.main.url(forResource: "pokemon", withExtension: "json")
        else {
            return Fail(error: PokemonError.invalidFileURL).eraseToAnyPublisher()
        }
        
        let passthroughSubject = PassthroughSubject<[Pokemon], Error>()
        
        DispatchQueue.global().async {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let pokemon = try decoder.decode([Pokemon].self, from: jsonData)
                
                passthroughSubject.send(pokemon)
                
            } catch {
                passthroughSubject.send(completion: .failure(error))
            }
        }
        
        return passthroughSubject.eraseToAnyPublisher()
    }
}

enum PokemonError: Error {
    case invalidFileURL
}

extension Ability {
    var uniqueTypes: [Pokemon.PokemonType] {
        Array(Set<Pokemon.PokemonType>(pokemon.map { $0.type1 }))
            .sorted(by: { $0.rawValue < $1.rawValue})
    }
}

extension Pokemon {
    var color: UIColor {
        type1.color
    }
    
    struct DefenseSummary {
        let value: Double
        let type: PokemonType
    }
    
    var defenseSummaries: [DefenseSummary] {
        [
            DefenseSummary(value: againstBug, type: .bug),
            DefenseSummary(value: againstDark, type: .dark),
            DefenseSummary(value: againstDragon, type: .dragon),
            DefenseSummary(value: againstElectric, type: .electric),
            DefenseSummary(value: againstFairy, type: .fairy),
            DefenseSummary(value: againstFight, type: .fighting),
            DefenseSummary(value: againstFire, type: .fire),
            DefenseSummary(value: againstFlying, type: .flying),
            DefenseSummary(value: againstGhost, type: .ghost),
            DefenseSummary(value: againstGrass, type: .grass),
            DefenseSummary(value: againstGround, type: .ground),
            DefenseSummary(value: againstIce, type: .ice),
            DefenseSummary(value: againstNormal, type: .normal),
            DefenseSummary(value: againstPoison, type: .poison),
            DefenseSummary(value: againstPsychic, type: .psychic),
            DefenseSummary(value: againstRock, type: .rock),
            DefenseSummary(value: againstSteel, type: .steel),
            DefenseSummary(value: againstWater, type: .water),
        ]
    }
}

extension Pokemon.PokemonType {
    var title: String {
        rawValue.capitalized
    }
    
    var image: UIImage? {
        UIImage(named: "PokemonTypes/\(rawValue)")
    }
    
    var smallImage: UIImage? {
        image.flatMap {
            $0.imageWith(newSize: CGSize(width: 50, height: 50))
        }
    }
    
    var smallerImage: UIImage? {
        image.flatMap {
            $0.imageWith(newSize: CGSize(width: 30, height: 30))
        }
    }
    
    var smallestImage: UIImage? {
        image.flatMap {
            $0.imageWith(newSize: CGSize(width: 20, height: 20))
        }
    }
    
    
    var color: UIColor {
        switch self {
        case .normal:
            return .fromRGB(0x919aa2)
        case .bug:
            return .fromRGB(0x83c400)
        case .dark:
            return .fromRGB(0x5c5465)
        case .dragon:
            return .fromRGB(0x016fc9)
        case .electric:
            return .fromRGB(0xfbd107)
        case .fairy:
            return .fromRGB(0xfb89ea)
        case .fighting:
            return .fromRGB(0xe0306a)
        case .fire:
            return .fromRGB(0xfe9740)
        case .flying:
            return .fromRGB(0x8aaae3)
        case .ghost:
            return .fromRGB(0x4c6ab2)
        case .grass:
            return .fromRGB(0x37c04b)
        case .ground:
            return .fromRGB(0xe87136)
        case .ice:
            return .fromRGB(0x4bd1c0)
        case .poison:
            return .fromRGB(0xb567cf)
        case .psychic:
            return .fromRGB(0xff6675)
        case .rock:
            return .fromRGB(0xc8b588)
        case .steel:
            return .fromRGB(0x5a8ea1)
        case .water:
            return .fromRGB(0x3592dd)
        }
    }
}

extension UIColor {
    static func fromRGB(_ rgbValue: Int) -> UIColor! {
        UIColor(
            red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}



extension Pokemon {
    static var previewPikachu: Pokemon {
        let pikachuJSON = """
        {
          "abilities": ["Static", "Lightningrod"],
          "against_bug": 1,
          "against_dark": 1,
          "against_dragon": 1,
          "against_electric": 0.5,
          "against_fairy": 1,
          "against_fight": 1,
          "against_fire": 1,
          "against_flying": 0.5,
          "against_ghost": 1,
          "against_grass": 1,
          "against_ground": 2,
          "against_ice": 1,
          "against_normal": 1,
          "against_poison": 1,
          "against_psychic": 1,
          "against_rock": 1,
          "against_steel": 0.5,
          "against_water": 1,
          "attack": 55,
          "base_egg_steps": 2560,
          "base_happiness": 70,
          "base_total": 320,
          "capture_rate": 190,
          "classfication": "Mouse Pokémon",
          "defense": 40,
          "experience_growth": 1000000,
          "height_m": 0.4,
          "hp": 35,
          "japanese_name": "Pikachuピカチュウ",
          "name": "Pikachu",
          "percentage_male": 50,
          "pokedex_number": 25,
          "sp_attack": 50,
          "sp_defense": 50,
          "speed": 90,
          "type1": "electric",
          
          "weight_kg": 6,
          "generation": 1,
          "is_legendary": 0
        }
        """
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try! decoder.decode(
            Pokemon.self,
            from: Data(pikachuJSON.utf8)
        )
    }
    
    static var previewStunfisk: Pokemon {
        let stunfiskJSON =
        """
        {
          "abilities": ["Static", "Limber", "Sand Veil"],
          "against_bug": 1,
          "against_dark": 1,
          "against_dragon": 1,
          "against_electric": 0,
          "against_fairy": 1,
          "against_fight": 1,
          "against_fire": 1,
          "against_flying": 0.5,
          "against_ghost": 1,
          "against_grass": 2,
          "against_ground": 2,
          "against_ice": 2,
          "against_normal": 1,
          "against_poison": 0.5,
          "against_psychic": 1,
          "against_rock": 0.5,
          "against_steel": 0.5,
          "against_water": 2,
          "attack": 66,
          "base_egg_steps": 5120,
          "base_happiness": 70,
          "base_total": 471,
          "capture_rate": 75,
          "classfication": "Trap Pokémon",
          "defense": 84,
          "experience_growth": 1000000,
          "height_m": 0.7,
          "hp": 109,
          "japanese_name": "Maggyoマッギョ",
          "name": "Stunfisk",
          "percentage_male": 50,
          "pokedex_number": 618,
          "sp_attack": 81,
          "sp_defense": 99,
          "speed": 32,
          "type1": "ground",
          "type2": "electric",
          "weight_kg": 11,
          "generation": 5,
          "is_legendary": 0
        }
        """
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try! decoder.decode(
            Pokemon.self,
            from: Data(stunfiskJSON.utf8)
        )
    }
}
