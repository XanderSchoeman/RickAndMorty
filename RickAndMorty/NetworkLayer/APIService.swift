//
//  APIService.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import Foundation

//todo extract URL in strings folder

//MARK: - NetworkLayer Interface/Boundary/Abstraction
protocol APIServiceProtocol {
    func fetchCharacters(page: Int, completion: @escaping (Result<[Character], Error>) -> Void)
    func fetchCharactersByName(name: String, page: Int, completion: @escaping (Result<[Character], Error>) -> Void)
}

//MARK: - Network Calls
class APIService: APIServiceProtocol {
    
    private let session: URLSession
    
    //In the init I implemented basic network caching and the capacity is set to a steady 100mb for memory and 500mb for disk capacity respectively since we are dealing with images coming from the network call.
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 100 * 1024 * 1024,
                                          diskCapacity: 500 * 1024 * 1024,
                                          diskPath: nil)
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
    }
    
    //This method fetches the entire character list in json format and uses pagination to display all of the characters in the UI.
    func fetchCharacters(page: Int, completion: @escaping (Result<[Character], Error>) -> Void) {
        let url = URL(string: "https://rickandmortyapi.com/api/character/?page=\(page)")!
        let request = URLRequest(url: url)
        
        //Network Caching via the session
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data coming through! Oh no!")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                let characters = apiResponse.results
                completion(.success(characters))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //This method fetches a character list in json format according to the text/name given in the UI searchbar and filters the character list for that name, also uses pagination to display all of the characters possible from the search query.
    func fetchCharactersByName(name: String, page: Int, completion: @escaping (Result<[Character], Error>) -> Void) {
        guard !name.isEmpty else {
            completion(.success([]))
            return
        }
        
        let queryName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://rickandmortyapi.com/api/character/?name=\(queryName)")!
        let request = URLRequest(url: url)
        
        //Network Caching via the session
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data coming through! Oh no!")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                let characters = apiResponse.results
                completion(.success(characters))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - APIResponseModel
    
    struct APIResponse: Codable {
        let results: [Character]
    }
}

