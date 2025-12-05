//
//  MemoryCardView.swift
//  Souvenirs
//
//  Created by Jean Martin on 05/12/2025.
//

import SwiftUI

struct MemoryCardView: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with gradient
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(memory.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white.opacity(0.9))
                        Text(memory.locationName)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
            }
            
            // Content area
            VStack(alignment: .leading, spacing: 16) {
                Text(memory.content)
                    .font(.body)
                    .lineLimit(8)
                    .foregroundColor(.primary)
                
                Divider()
                
                // Footer
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(memory.likesCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if memory.hasAudio {
                        HStack(spacing: 4) {
                            Image(systemName: "waveform")
                                .foregroundColor(.blue)
                            Text("Voice")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(memory.createdDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // App branding
                HStack {
                    Spacer()
                    Text("Souvenirs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "map.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 600)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    MemoryCardView(memory: Memory(
        title: "Refugee Camp",
        content: "I spent one month in an UNHCR camp outside Matadi in 1999. The experience was challenging but the community support was incredible.",
        locationName: "Matadi, DRC"
    ))
}
