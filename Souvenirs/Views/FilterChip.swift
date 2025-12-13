//
//  FilterChip.swift
//  Souvenirs
//
//  Created by Jean Martin on 12/12/2025.
//

import SwiftUI

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    
    var body: some View {
        
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                
            } //button end
        } //hstack
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(16)
        
    } //body end
} //struct end

#Preview {
    FilterChip(text: "Paris", onRemove: {
        
        print("Filter Removed!")
    })
    .padding()
}
