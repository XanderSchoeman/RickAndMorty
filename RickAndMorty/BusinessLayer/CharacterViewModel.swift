//
//  CharacterViewModel.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import Foundation

class CharacterViewModel: ObservableObject {
    @Published var characters: [CharacterWithFavorite] = []
    @Published var favorites: [Character] = []
    @Published var searchText = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    private var apiService: APIServiceProtocol
    private var isSearchActive: Bool { !searchText.isEmpty }
    var currentPage = 1
    var canLoadMorePages = true
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        fetchCharacters(page: currentPage)
    }
    
    //MARK: - Network Calls
    
    func fetchCharacters(page: Int) {
        guard canLoadMorePages else { return }
        
        apiService.fetchCharacters(page: currentPage) { [weak self] result in
            switch result {
            case .success(let newCharacters):
                DispatchQueue.main.async {
                    let newCharactersWithFavorite = newCharacters.map { CharacterWithFavorite(character: $0, isFavorite: false) }
                    self?.characters.append(contentsOf: newCharactersWithFavorite)
                    if newCharacters.isEmpty {
                        self?.canLoadMorePages = false
                    } else {
                        DispatchQueue.main.async {
                            self?.currentPage += 1
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.alertMessage = "An error occurred: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }
    
    private func searchCharactersByName(page: Int) {
        apiService.fetchCharactersByName(name: searchText, page: page) { [weak self] result in
            switch result {
            case .success(let newCharacters):
                DispatchQueue.main.async {
                    let newCharactersWithFavorite = newCharacters.map { CharacterWithFavorite(character: $0, isFavorite: false) }
                    
                    if page == 1 {
                        self?.characters = newCharactersWithFavorite
                    } else {
                        self?.characters.append(contentsOf: newCharactersWithFavorite.filter { newCharacterWithFavorite in
                            !(self?.characters.contains(where: { $0.character.id == newCharacterWithFavorite.character.id }) ?? true)
                        })
                    }
                    
                    if newCharacters.isEmpty {
                        self?.canLoadMorePages = false
                        self?.alertMessage = "No data found."
                        self?.showAlert = true
                    }
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self?.alertMessage = "No characters found for '\(self?.searchText ?? "")'."
                    self?.showAlert = true
                }
            }
            
            DispatchQueue.main.async {
                self?.currentPage += 1
            }
        }
    }
    
    //MARK: - Favourite functionality functions
    
    //favourite functionality with temporary storage
    func toggleFavorite(character: CharacterWithFavorite) {
        if let index = characters.firstIndex(where: { $0.character.id == character.character.id }) {
            characters[index].isFavorite.toggle()
            //todo add actual persistent storage
        }
    }
    
    //This method is used when true to add a character to favourites and when false to remove one
    func toggleFavorite(character: Character) -> Bool {
        if let index = favorites.firstIndex(where: { $0.id == character.id }) {
            favorites.remove(at: index)
            return false
        } else {
            favorites.append(character)
            return true
        }
    }
    
    //To check if a character is favourite
    func isFavorite(character: Character) -> Bool {
        favorites.contains { $0.id == character.id }
    }
    
    //MARK: - Character Functions
    
    //To load more characters when scrolling down via pagination
    func loadMoreCharacters() {
        guard canLoadMorePages else { return }
        
        if isSearchActive {
            searchCharactersByName(page: currentPage)
        } else {
            fetchCharacters(page: currentPage)
        }
    }
    
    func searchCharactersByName() {
        if searchText.isEmpty {
            clearCache()
            fetchFreshCharacters()
        } else {
            currentPage = 1
            canLoadMorePages = true
            loadMoreCharacters()
        }
    }
    
    private func fetchFreshCharacters() {
        currentPage = 1
        canLoadMorePages = true
        characters.removeAll()
        loadMoreCharacters()
    }
    
    func isLastCharacter(_ character: CharacterWithFavorite) -> Bool {
        guard let lastCharacter = characters.last else { return false }
        return lastCharacter.id == character.id
    }
    
    //MARK: - Miscellaneous functions
    
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
}
