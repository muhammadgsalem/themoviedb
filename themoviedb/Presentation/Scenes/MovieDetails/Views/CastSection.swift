//
//  CastSection.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository
import SwiftUI

struct CastSection: View {
    let title: String
    let members: [CastMemberDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            ForEach(members) { member in
                Text(member.name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
