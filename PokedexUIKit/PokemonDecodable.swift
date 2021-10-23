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
    
    struct AttackSummary {
        let value: Double
        let type: PokemonType
    }
    
    var attackSummaries: [AttackSummary] {
        [
            AttackSummary(value: againstBug, type: .bug),
            AttackSummary(value: againstDark, type: .dark),
            AttackSummary(value: againstDragon, type: .dragon),
            AttackSummary(value: againstElectric, type: .electric),
            AttackSummary(value: againstFairy, type: .fairy),
            AttackSummary(value: againstFight, type: .fighting),
            AttackSummary(value: againstFire, type: .fire),
            AttackSummary(value: againstFlying, type: .flying),
            AttackSummary(value: againstGhost, type: .ghost),
            AttackSummary(value: againstGrass, type: .grass),
            AttackSummary(value: againstGround, type: .ground),
            AttackSummary(value: againstIce, type: .ice),
            AttackSummary(value: againstNormal, type: .normal),
            AttackSummary(value: againstPoison, type: .poison),
            AttackSummary(value: againstPsychic, type: .psychic),
            AttackSummary(value: againstRock, type: .rock),
            AttackSummary(value: againstSteel, type: .steel),
            AttackSummary(value: againstWater, type: .water),
        ]
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
    
    var smallerImage: UIImage? {
        image.flatMap {
            $0.imageWith(newSize: CGSize(width: 30, height: 30))
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
