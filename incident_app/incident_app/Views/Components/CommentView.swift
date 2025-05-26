//
//  CommentView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct CommentView: View {
    let comment: IncidentComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.user.fullName)
                    .font(.bodyMedium.weight(.semibold))
                    .foregroundColor(.theme.textPrimary)
                
                Spacer()
                
                Text(comment.formattedDate)
                    .font(.bodySmall)
                    .foregroundColor(.theme.textSecondary)
            }
            
            Text(comment.content)
                .font(.bodyMedium)
                .foregroundColor(.theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color.theme.background)
        .cornerRadius(8)
    }
}
