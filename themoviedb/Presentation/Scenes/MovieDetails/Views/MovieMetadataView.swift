//
//  MovieMetadataView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import SwiftUI

struct MovieMetadataView: View {
    let year: Int
    let rating: String
    let voteCount: Int
    let font: Font
    
    var body: some View {
        HStack(spacing: 4) {
            // Year
            Label {
                Text(String(format: "%.0f", Double(year)))
            } icon: {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            
            // Rating
            Label {
                Text(rating)
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            // Vote count
            Label {
                Text("\(voteCount)")
                    .foregroundColor(.gray)
            } icon: {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.gray)
            }
        }
        .font(font)
    }
}
