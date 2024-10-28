//
//  CharacterDetailsView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//


import DataRepository
import SwiftUI

struct MovieDetailsView: View {
    let movie: MovieDTO
    let onBackActionSelected: () -> Void
    let imageLoadingService: ImageCacheService

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                movieImageView
                movieInfoView
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: adjustScrollViewBehavior)
    }
    
    private var movieImageView: some View {
        ZStack(alignment: .topLeading) {
            if let url = movie.posterURL {
                MovieAsyncImage(url: url, imageCache: imageLoadingService)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom, 10)
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button(action: performBackAction) {
            Image(systemName: "circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .overlay(
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                )
                .frame(width: 40, height: 40)
                .shadow(radius: 20)
        }
        .padding(.top, 60)
        .padding(.leading, 20)
    }
    
    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                movieBasicInfo
                Spacer()
                    .shadow(radius: 5)
            }
            
            movieLocationInfo
        }
        .padding()
    }
    
    private var movieBasicInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title)
                .font(.title)
                .bold()
            HStack(spacing: 2) {
                Text("\(movie.releaseYear)")
                Text("• \(movie.formattedRating)")
                Text("• \(movie.voteCount)")
                    .foregroundColor(.gray)
            }
            .font(.subheadline)
        }
    }
    
    private var movieLocationInfo: some View {
        HStack(spacing: 4) {
            Text(movie.overview)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .font(.title3)
    }
    
    private func performBackAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            onBackActionSelected()
        }
    }
    
    private func adjustScrollViewBehavior() {
        DispatchQueue.main.async {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
    }
}
