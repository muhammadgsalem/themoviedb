//
//  MovieDetailsView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository
import SwiftUI

struct MovieDetailsView: View {
    @StateObject private var viewModel: MovieDetailsViewModelWrapper
    let movie: MovieDTO
    let onBackActionSelected: () -> Void
    let imageLoadingService: ImageCacheService

    init(movie: MovieDTO,
         viewModel: MovieDetailsViewModelProtocol,
         imageLoadingService: ImageCacheService,
         onBackActionSelected: @escaping () -> Void)
    {
        self.movie = movie
        self._viewModel = StateObject(wrappedValue: MovieDetailsViewModelWrapper(wrapped: viewModel))
        self.imageLoadingService = imageLoadingService
        self.onBackActionSelected = onBackActionSelected
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                movieImageView
                movieInfoView
                
                // Similar Movies Section
                if !viewModel.movies.moviesByYear.isEmpty {
                    similarMoviesSection
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            adjustScrollViewBehavior()
            Task {
                await viewModel.loadsSimilarMovies()
            }
        }
    }
    
    private var movieImageView: some View {
        ZStack(alignment: .topLeading) {
            if let url = movie.posterURL {
                MovieAsyncImage(url: url, imageCache: imageLoadingService)
                    .frame(height: 400)
                    .frame(maxWidth: .infinity)
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
    
    private var similarMoviesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Similar Movies")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Sort all movies by popularity before taking top 5
                    let allMovies = viewModel.movies.moviesByYear.values
                        .flatMap { $0 }
                        .sorted { $0.popularity > $1.popularity }
                        .prefix(5)
                                    
                    ForEach(Array(allMovies)) { movie in
                        SimilarMovieCard(movie: movie,
                                         imageLoadingService: imageLoadingService)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 24)
    }

    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                movieBasicInfo
                Spacer()
                    .shadow(radius: 5)
            }
            
            movieOverviewInfo
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
    
    private var movieOverviewInfo: some View {
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
