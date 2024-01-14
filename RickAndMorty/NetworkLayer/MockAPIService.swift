//
//  MockAPIService.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import Foundation

class MockAPIService: APIServiceProtocol {
    
    var fetchCharactersResult: Result<[Character], Error> = .success([])
    var fetchCharactersByNameResult: Result<[Character], Error> = .success([])
    
    func fetchCharacters(page: Int, completion: @escaping (Result<[Character], Error>) -> Void) {
        completion(fetchCharactersResult)
    }
    
    func fetchCharactersByName(name: String, page: Int, completion: @escaping (Result<[Character], Error>) -> Void) {
        completion(fetchCharactersByNameResult)
    }
    
}
