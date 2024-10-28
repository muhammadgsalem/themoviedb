//
//  MovieCastView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository
import SwiftUI

struct MovieCastView: View {
    let cast: CastDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !cast.directors.isEmpty {
                CastSection(title: "Directors", members: cast.directors)
            }
            
            if !cast.actors.isEmpty {
                CastSection(title: "Actors", members: cast.actors)
            }
        }
        .padding(.top, 8)
    }
}
