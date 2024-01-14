//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Xander Schoeman on 2024/01/14.
//

import SwiftUI

struct CharacterDetailView: View {
    
    @EnvironmentObject var viewModel: CharacterViewModel
    var character: CharacterWithFavorite
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                AsyncImage(url: URL(string: character.character.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.fill.questionmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.top, 20)
                
                Text(character.character.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Character Details")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Status: \(character.character.status)")
                        Text("Species: \(character.character.species)")
                        Text("Gender: \(character.character.gender)")
                        Text("Location: \(character.character.location.name)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .groupBoxStyle(CharacterGroupBoxStyle())
                
                Button(action: {
                    let isFav = viewModel.toggleFavorite(character: character.character)
                    alertMessage = isFav ? "\(character.character.name) added to favorites" : "\(character.character.name) removed from favorites"
                    showAlert = true
                }) {
                    Image(systemName: viewModel.isFavorite(character: character.character) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(character: character.character) ? .red : .gray)
                        .imageScale(.large)
                        .font(.system(size: 24))
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Favorite Character"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
            }
            .padding()
            
        }
        .navigationTitle(character.character.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CharacterGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            configuration.content
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.75, green: 1.0, blue: 0.0)))
        }
        .padding(.horizontal)
    }
}
