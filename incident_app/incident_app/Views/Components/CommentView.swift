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
                // User avatar placeholder
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.theme.secondary)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.user.fullName)
                        .font(.bodyMedium.weight(.semibold))
                        .foregroundColor(.theme.textPrimary)
                    
                    Text(comment.formattedDate)
                        .font(.bodySmall)
                        .foregroundColor(.theme.textSecondary)
                }
                
                Spacer()
            }
            
            Text(comment.content)
                .font(.bodyMedium)
                .foregroundColor(.theme.textPrimary)
                .padding(12)
                .background(Color.theme.background)
                .cornerRadius(10)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
}
