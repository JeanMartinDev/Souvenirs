//
//  MemoryDetailView.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import SwiftUI
import MapKit

struct MemoryDetailView: View {
    let memory: Memory
    @State private var audioManager = AudioRecorderManager()
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 20) {
                    //map section, if coordinates are available
                    if let latitude = memory.latitude,
                       let longitude = memory.longitude {
                        
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        ))) {
                            Annotation(memory.locationName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                                
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                            } //annotation end
                            
                        } //inner map end
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                    } //if let end
                    
                    //LOCATION
                    VStack(alignment: .leading, spacing: 8) {
                        Label(memory.locationName, systemImage: "location.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(memory.createdDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if memory.isAnonymous {
                            Label("Posted anonymously", systemImage: "person.fill.questionmark")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                        } //inner if loop end
                        
                    } //inner vstack end
                    .padding(.horizontal)
                    
                    Divider()
                    
                    //CONTENT
                    VStack (alignment: .leading, spacing: 12) {
                        Text("Story")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(memory.content)
                            .font(.body)
                            .lineSpacing(4)
                        
                    } //inner vstack 2 end
                    .padding(.horizontal)
                    
                    //Audio player (if audio exists)
                    if memory.hasAudio, let audioFileName = memory.audioFileName {
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voice Recording")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button(action: {
                                    toggleAudioPlayback(filename: audioFileName)
                                }) {
                                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                    
                                } //button end
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    if audioManager.isPlaying {
                                        Text(formatTime(audioManager.playbackTime))
                                            .font(.system(.body, design: .monospaced))
                                        
                                    } //inner if statement end
                                    
                                    Text(audioManager.isPlaying ? "Playing..." : "Tap to play")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                } //inner audio vstack end
                                
                                Spacer()
                                
                            } //audio hstack end
                            .padding()
                            .background(Color(.blue).opacity(0.1))
                            .cornerRadius(12)
                            
                        } //audio vstack end
                        .padding(.horizontal)
                        
                    } //inner if statement end
                    
                    Divider()
                        .padding(.horizontal)
                    
                    //LIKES SECTION
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(memory.likesCount) likes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }//hstack end
                    .padding(.horizontal)
                    
                    Spacer()
                    
                }//vstack end
                .navigationBarTitle(memory.title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button( action: { shareAsText() }) {
                                Label("Share as Text", systemImage: "text.quote")
                                
                            } //button end
                            
                            Button(action: { shareAsImage() }) {
                                Label("Share as Image", systemImage: "photo")
                            }
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        } //menu end
                        
                    } //tool bar item 1
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                            
                        } // button end
                        
                    }//tool bar item end
                }//tool bar end
                
            }//scrollview end
            
        }//navigation stack end
    } // body end
    
    //MARK: LET US ADD FUNCTIONS HERE
    private func toggleAudioPlayback(filename: String) {
        guard let audioURL = audioManager.getAudioURL(for: filename) else {
            return
        } //guad end
        
        if audioManager.isPlaying {
            audioManager.pausePlayback()
        } else {
            do {
                if audioManager.playbackTime == 0 {
                    try audioManager.playAudio(from: audioURL)
                    
                } else {
                    audioManager.resumePlayback()
                } //inner if end
                
            } catch {
                print("Failed to play audio: \(error)")
                
            } //catch end
            
        } //if statement end
    } //func 1 end
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
        
    } //func 2 end
    
    //MARK: SHARE ACTIONS
    private func shareAsText() {
        ShareManager.shared.shareMemoryAsText(memory: memory)
    }
    
    private func shareAsImage() {
        ShareManager.shared.shareMemoryAsImage(memory: memory)
        
    } //func 4 end
} //struct end

#Preview {
    let previewMemory = Memory(
        title: "Refugee camp",
        content: "I spent 1 month in an HCR-managed refugee camp outside of Matadi, DRC",
        locationName: "Matadi, DRC",
        latitude: -5.8167,
        longitude: 13.45)
    
    return MemoryDetailView(memory: previewMemory)
}
