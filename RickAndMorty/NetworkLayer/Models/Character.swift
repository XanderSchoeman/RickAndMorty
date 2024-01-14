//
//  Character.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import Foundation

//MARK: - Character Models

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: String
    let location: Location
}

struct Location: Codable {
    let name: String
}

//This struct is needed to be able to favourite a specific character according to the ID.
struct CharacterWithFavorite: Identifiable {
    let character: Character
    var isFavorite: Bool
    
    var id: Int {
        character.id
    }
}
