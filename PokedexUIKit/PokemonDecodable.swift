//
//  PokemonDecodable.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import Combine
import Foundation

struct Pokemon: Decodable, Hashable {
    
    enum PokemonType: String, CaseIterable {
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
        
        case notApplicable = ""
        
        case unknown
    }
    
    /*"against_bug": 1,
    "against_dark": 1,
    "against_dragon": 1,
    "against_electric": 0.5,
    "against_fairy": 0.5,
    "against_fight": 0.5,
    "against_fire": 2,
    "against_flying": 2,
    "against_ghost": 1,
    "against_grass": 0.25,
    "against_ground": 1,
    "against_ice": 2,
    "against_normal": 1,
    "against_poison": 1,
    "against_psychic": 2,
    "against_rock": 1,
    "against_steel": 1,
    "against_water": 0.5,*/
    
    let againstBug: Double
    let againstDark: Double
    let againstDragon: Double
    let name: String
    let type1: PokemonType
    let type2: PokemonType
    
    var index: Int?
    var imageURL: URL?
}

extension Pokemon {
    static func pokemonOfType(type: Pokemon.PokemonType) -> AnyPublisher<[Pokemon], Error> {
        decodeAllPokemon()
            .tryMap { allPokemon in
                allPokemon.filter { $0.type1 == type || $0.type2 == type }
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
                
                let indexedPokemon = pokemon.enumerated().map { index, pokemon -> Pokemon in
                    var indexedPokemon = pokemon
                    indexedPokemon.index = index + 1
                    indexedPokemon.imageURL = URL(string: "https://d18bqzgu48wusx.cloudfront.net/\(index + 1).png")!
                    return indexedPokemon
                }
                
                passthroughSubject.send(indexedPokemon)
                
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


extension Pokemon.PokemonType: Decodable {
    public init(from decoder: Decoder) throws {
        self = try Pokemon.PokemonType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
