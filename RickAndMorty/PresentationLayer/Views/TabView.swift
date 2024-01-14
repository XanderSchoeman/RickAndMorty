//
//  TabView.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel = CharacterViewModel()

    var body: some View {
        TabView {
            CharacterListView()
                .tabItem {
                    Label("Browse", systemImage: "list.dash")
                }
                .environmentObject(viewModel)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .environmentObject(viewModel)
        }
    }
}

struct FavoritesView: View {
    @EnvironmentObject var viewModel: CharacterViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.favorites.isEmpty {
                Text("No favorite characters so far")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                    .navigationTitle("Favorites")
            } else {
                List(viewModel.favorites, id: \.id) { character in
                    NavigationLink(destination: CharacterDetailView(character: CharacterWithFavorite(character: character, isFavorite: true)).environmentObject(viewModel)) {
                        CharacterRow(character: character)
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
}
