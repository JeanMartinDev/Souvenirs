//
//  AudioRecorderView.swift
//  Souvenirs
//
//  Created by Jean Martin on 01/12/2025.
//

import SwiftUI

struct AudioRecorderView: View {
    @State private var audioManager = AudioRecorderManager()
    @State private var recordedAudioURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animatewave = false
    
    let onAudioRecorded: (URL) -> Void
    let onCancel: () -> Void
    
    
    
    var body: some View {
        
        VStack (spacing: 30) {
            //title
            Text(audioManager.isRecording ? "Recording..." : recordedAudioURL != nil ? "Recording Ready" : "Start your Memory")
                .font(.title2)
                .fontWeight(.semibold)
            
            //waveform animation when recording is on
            if audioManager.isRecording {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red)
                            .frame(width: 6, height: getWaveHeight(for: index))
                    }//foreach end
                    
                }//hstack end
                .frame(height: 60)
                
            } //if loop end
            
            //TIME DISPLAY
            if audioManager.isRecording {
                Text(formatTime(audioManager.recordingTime))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.red)
                
            } else if audioManager.isPlaying {
                Text(formatTime(audioManager.playbackTime))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.blue)
            } //if loop 2 end
            
            Spacer()
            
            //CONTROLS
            if recordedAudioURL == nil {
                //recording controls
                recordingControls
                
            } else {
                //playback Controls
                playbackControls
            } // if loop 3 end
            
            Spacer()
            
        } //vstack end
        .padding(40)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }// alert end
        
    } //body end
    
    //MARK: RECORDING CONTROLS
    private var recordingControls: some View {
        VStack(spacing: 20) {
            if audioManager.isRecording {
                //stop button
                Button(action: stopRecording) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                    } //zstack end
                } //button end
                
                Text("Tap to Stop")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            } else {
                //start recording button
                Button(action: startRecording) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                        
                    } //zstack end
                } //button 2 end
                
                Text("Tap to Record")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button("Cancel") {
                    onCancel()
                    
                } //button 3 end
                .padding(.top)
                
            } //if loop 1 end
            
        } //vstack end
        
    } // some view 2 end
    
    //MARK: PLAYBACK CONTROLS
    private var playbackControls: some View {
        VStack(spacing: 30) {
            //play:pause button
            HStack(spacing: 40) {
                
                //delete
                Button(action: deleteRecording) {
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                        
                } //button 1 end
                //play:pause
                Button(action: togglePlayback) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                        .clipShape(Circle())
                } //button 2 end
                
                //use recording
                Button(action: useRecording) {
                    Image(systemName: "checkmark")
                        .font(.title)
                        .foregroundColor(.green)
                        .frame(width: 60, height: 60)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                } //button 3 end
                
            } //hstack end
            
            HStack(spacing: 40) {
                Text("Delete")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(audioManager.isPlaying ? "Pause" : "Play")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 60)
                
                Text("Use")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }//hstack 2 end
            
            
        }//vstack end
        
    }//some view 3 end
    
    //MARK: ACTIONS
    private func startRecording() {
        task {
            do {
                _ = try await audioManager.startRecording()
                
                //START WAVE ANIMATION
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    animatewave = true
                }//with animation end
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                
            } //catch end
            
        }//task end
        
    } //func end
    
    private func stopRecording() {
        if let url = audioManager.stopRecording() {
            recordedAudioURL = url
        }
        animatewave = false 
        
    } //func 2 end
    
    private func deleteRecording() {
        audioManager.stopPlayback()
        audioManager.cancelRecording()
        recordedAudioURL = nil
        
    } //func 3 end
    
    private func togglePlayback() {
        guard let url = recordedAudioURL else { return }
        
        if audioManager.isPlaying {
            audioManager.pausePlayback()
            
        } else {
            do {
                if audioManager.playbackTime == 0 {
                    try audioManager.playAudio(from: url)
                    
                } else {
                    audioManager.resumePlayback()
                } //inner if end
                
            } catch {
                errorMessage = "Failed to play audio"
                showError = true
                
            } //do end
        } //if loop end
         
    } //func 4 end
    
    private func useRecording() {
        guard let url = recordedAudioURL else { return }
        
        onAudioRecorded(url)
        
    } //func 5 end
    
    //MARK: HELPERS
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
        
    } //func 1 end
    
    private func getWaveHeight(for index: Int) -> CGFloat {
        
        if !audioManager.isRecording {
            return 20
            
        }//if end
        
        let baseHeights: [CGFloat] = [20, 40, 60, 40, 20]
        let variance: CGFloat = animatewave ? 10: 0
        
        return baseHeights[index] + variance
        
    }//FUNC END
}//struct end

#Preview {
    AudioRecorderView(
        onAudioRecorded: { _ in }, onCancel: {}
    )
}
