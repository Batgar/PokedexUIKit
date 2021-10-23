//
//  PokemonDecodable.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import Combine
import Foundation
import UIKit

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
    let attack: Double
    var heightM: Double?
    let name: String
    let type1: PokemonType
    let type2: PokemonType
    var weightKg: Double?
    
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

extension Pokemon {
    var color: UIColor {
        type1.color ?? UIColor.yellow
    }
}

extension Pokemon.PokemonType: Decodable {
    public init(from decoder: Decoder) throws {
        self = try Pokemon.PokemonType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension Pokemon.PokemonType {
    var title: String? {
        switch self {
        case .unknown:
            return nil
        case .notApplicable:
            return nil
        default:
            return rawValue.capitalized
        }
    }
    
    var isDisplayable: Bool {
        switch self {
        case .unknown:
            return false
        case .notApplicable:
            return false
        default:
            return true
        }
    }
    
    static var displayableTypes: [Pokemon.PokemonType] {
        Pokemon.PokemonType.allCases.compactMap { pokemonType in
            pokemonType.isDisplayable ? pokemonType : nil
        }
    }
    
    var image: UIImage? {
        guard isDisplayable else { return nil }
        
        return UIImage(named: "PokemonTypes/\(rawValue)")
    }
    
    var smallImage: UIImage? {
        image.flatMap {
            $0.imageWith(newSize: CGSize(width: 50, height: 50))
        }
    }
    
    var color: UIColor? {
        guard isDisplayable else { return nil }
        switch self {
        case .normal:
            return .gray
        case .notApplicable, .unknown:
            return nil
        case .bug:
            return .green
        case .dark:
            return .darkGray
        case .dragon:
            return .blue
        case .electric:
            return .yellow
        case .fairy:
            return .systemPink
        case .fighting:
            return .red
        case .fire:
            return .orange
        case .flying:
            return .lightGray
        case .ghost:
            return .blue
        case .grass:
            return .green
        case .ground:
            return .brown
        case .ice:
            return .systemTeal
        case .poison:
            return .purple
        case .psychic:
            return .red
        case .rock:
            return .brown
        case .steel:
            return .gray
        case .water:
            return .blue
        }
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
