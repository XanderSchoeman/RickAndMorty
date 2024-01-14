//
//  RickAndMortyTests.swift
//  RickAndMortyTests
//
//  Created by Xander Schoeman on 2024/01/14.
//

import XCTest
@testable import RickAndMorty

final class CharacterViewModelTests: XCTestCase {
    var viewModel: CharacterViewModel!
    var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = CharacterViewModel(apiService: mockAPIService)
        
        let defaultCharacters = [Character(id: 1, name: "Rick", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))]
        mockAPIService.fetchCharactersResult = .success(defaultCharacters)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func testFetchCharactersSuccess() {
        let expectedCharacters = [Character(id: 1, name: "Rick", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))]
        mockAPIService.fetchCharactersResult = .success(expectedCharacters)
        let expectation = XCTestExpectation(description: "Fetch characters expectation")
        
        viewModel.fetchCharacters(page: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.characters.count, expectedCharacters.count)
    }
    
    func testFetchCharactersFailure() {
        let error = NSError(domain: "testError", code: 0, userInfo: nil)
        mockAPIService.fetchCharactersResult = .failure(error)
        let expectation = XCTestExpectation(description: "Fetch characters failure expectation")

        viewModel.fetchCharacters(page: 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertTrue(viewModel.showAlert, "Show alert should be true when the fetch failed")
        XCTAssertEqual(viewModel.alertMessage, "An error occurred: \(error.localizedDescription)")
    }
    
    func testSearchCharactersSuccess() {
        let searchQuery = "Rick"
        viewModel.searchText = searchQuery
        let expectedCharacters = [Character(id: 1, name: "Rick", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))]
        mockAPIService.fetchCharactersByNameResult = .success(expectedCharacters)
        let expectation = XCTestExpectation(description: "Search characters success expectation")
        
        viewModel.searchCharactersByName()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.characters.count, expectedCharacters.count)
    }
    
    func testSearchCharactersNoResults() {
        let searchQuery = "Unknown"
        viewModel.searchText = searchQuery
        mockAPIService.fetchCharactersByNameResult = .success([])
        let expectation = XCTestExpectation(description: "Search characters have no results expectation")
        
        viewModel.searchCharactersByName()
        
        DispatchQueue
            .main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertTrue(viewModel.characters.isEmpty, "Characters should be empty when the search has no results")
        XCTAssertTrue(viewModel.showAlert, "Show alert should be true when there are no search results")
        XCTAssertEqual(viewModel.alertMessage, "No data found.")
    }
    
    func testSearchCharactersFailure() {
        let searchQuery = "Rick"
        viewModel.searchText = searchQuery
        let error = NSError(domain: "testError", code: 0, userInfo: nil)
        mockAPIService.fetchCharactersByNameResult = .failure(error)
        let expectation = XCTestExpectation(description: "Search characters failure expectation")

        viewModel.searchCharactersByName()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertTrue(viewModel.showAlert, "Show alert should be true on search failure")
        XCTAssertEqual(viewModel.alertMessage, "No characters found for '\(searchQuery)'.")
    }
    
    func testAddFavorite() {
        let character = Character(id: 1, name: "Rick", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))
        let characterWithFavorite = CharacterWithFavorite(character: character, isFavorite: false)
        
        let isFavoriteNow = viewModel.toggleFavorite(character: character)
        
        XCTAssertTrue(isFavoriteNow, "Character should be marked as favorite")
        XCTAssertTrue(viewModel.isFavorite(character: character), "The character should be in the favorites array")
    }
    
    func testRemoveFavorite() {
        let character = Character(id: 2, name: "Morty", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))
        viewModel.favorites.append(character)
        
        let isFavoriteNow = viewModel.toggleFavorite(character: character)
        
        XCTAssertFalse(isFavoriteNow, "Character should be unmarked as favorite")
        XCTAssertFalse(viewModel.isFavorite(character: character), "The character should be removed from the favorites array")
    }
    
    func testPaginationNoMoreData() {
        let characters = [Character(id: 1, name: "Rick", status: "Alive", species: "Human", gender: "Male", image: "url", location: Location(name: "Earth"))]
        mockAPIService.fetchCharactersResult = .success(characters)
        let expectation = XCTestExpectation(description: "No more data pagination expectation")
        
        viewModel.loadMoreCharacters()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mockAPIService.fetchCharactersResult = .success([])
            self.viewModel.loadMoreCharacters()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.5)
        XCTAssertEqual(viewModel.characters.count, characters.count)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.canLoadMorePages)
    }
}
