//
//  MovieDetailsView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository
import SwiftUI

struct MovieDetailsView: View {
    @StateObject private var viewModel: MovieDetailsViewModel
    let movie: MovieDTO
    let onBackActionSelected: () -> Void
    let imageLoadingService: ImageCacheService
    
    init(movie: MovieDTO,
         viewModel: MovieDetailsViewModel,
         imageLoadingService: ImageCacheService,
         onBackActionSelected: @escaping () -> Void)
    {
        self.movie = movie
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.imageLoadingService = imageLoadingService
        self.onBackActionSelected = onBackActionSelected
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                movieImageView
                movieInfoView
                
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
    
    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.title)
                    .bold()
                
                MovieMetadataView(
                    year: movie.releaseYear,
                    rating: movie.formattedRating,
                    voteCount: movie.voteCount,
                    font: .subheadline
                )
            }
            
            // Overview
            Text(movie.overview)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private var similarMoviesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Similar Movies")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    let similarMovies = viewModel.movies.moviesByYear.values
                        .flatMap { $0 }
                        .sorted { $0.popularity > $1.popularity }
                        .prefix(5)
                    
                    ForEach(Array(similarMovies)) { movie in
                        SimilarMovieView(
                            movie: movie,
                            imageLoadingService: imageLoadingService,
                            cast: viewModel.movieCasts[movie.id]
                        )
                        .onAppear {
                            if viewModel.movieCasts[movie.id] == nil {
                                Task {
                                    await viewModel.loadCreditsForMovie(movie.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 24)
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

//struct MovieDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailsView(
//            movie: MovieDTO.mock,
//            viewModel: MovieDetailsViewModel(
//                fetchSimilarMoviesUseCase: MockFetchSimilarMoviesUseCase(),
//                movieRepository: MockMovieRepository(),
//                movie: .mock
//            ),
//            imageLoadingService: MockImageCacheService(),
//            onBackActionSelected: {}
//        )
//    }
//}
