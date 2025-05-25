//
//  CustomTextField.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    @State private var isTextVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.theme.textSecondary)
                .frame(width: 24)
            
            if isSecure && !isTextVisible {
                SecureField(placeholder, text: $text)
                    .font(.bodyMedium)
                    .foregroundColor(.theme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(.bodyMedium)
                    .foregroundColor(.theme.textPrimary)
            }
            
            if isSecure {
                Button(action: {
                    isTextVisible.toggle()
                }) {
                    Image(systemName: isTextVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.theme.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
}
