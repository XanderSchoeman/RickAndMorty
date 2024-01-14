//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import SwiftUI

struct CharacterListView: View {
    
    @EnvironmentObject var viewModel: CharacterViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search by name", text: $viewModel.searchText)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onSubmit {
                        viewModel.searchCharactersByName()
                    }
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.searchCharactersByName()
                    }
                
                List(viewModel.characters) { characterWithFavorite in
                    NavigationLink(destination: CharacterDetailView(character: characterWithFavorite).environmentObject(viewModel)) {
                        CharacterRow(character: characterWithFavorite.character)
                    }
                    .onAppear {
                        if self.isLastCharacter(characterWithFavorite.character) {
                            self.viewModel.loadMoreCharacters()
                        }
                    }
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(title: Text("Search Result"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle("Rick and Morty")
        }
    }
    
    private func isLastCharacter(_ character: Character) -> Bool {
        if let lastCharacter = viewModel.characters.last {
            return lastCharacter.id == character.id
        }
        return false
    }
}

struct CharacterRow: View {
    var character: Character
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: character.image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}
