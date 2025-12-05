//
//  AudioRecorderManager.swift
//  Souvenirs
//
//  Created by Jean Martin on 01/12/2025.
//

import Foundation
import AVFoundation
import SwiftUI

@Observable
class AudioRecorderManager: NSObject {
    var isRecording = false
    var isPlaying = false
    var recordingTime: TimeInterval = 0
    var playbackTime: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    
    private var currentRecordingURL: URL?
    
    // MARK: - Recording
    func startRecording() async throws -> URL {
        print("🎤 AudioRecorderManager: startRecording called")
        
        // Request microphone permission using AVAudioSession
        print("🎤 Requesting microphone permission...")
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Request permission
        let permissionGranted = await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        print("🎤 Permission granted: \(permissionGranted)")
        
        guard permissionGranted else {
            print("❌ Permission denied")
            throw AudioError.permissionDenied
        }
        
        // Configure audio session
        print("🎤 Configuring audio session...")
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
        print("✅ Audio session configured")
        
        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)
        print("🎤 Recording to: \(fileURL)")
        
        // Recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Create and start recorder
        print("🎤 Creating audio recorder...")
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        
        guard let recorder = audioRecorder else {
            print("❌ Failed to create audio recorder")
            throw AudioError.recordingFailed
        }
        
        let success = recorder.record()
        print("🎤 recorder.record() returned: \(success)")
        
        if !success {
            print("❌ Failed to start recording")
            throw AudioError.recordingFailed
        }
        
        print("✅ Recording started successfully!")
        
        currentRecordingURL = fileURL
        isRecording = true
        recordingTime = 0
        
        // Start timer
        startRecordingTimer()
        print("🎤 Timer started")
        
        return fileURL
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        stopRecordingTimer()
        
        return currentRecordingURL
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopRecordingTimer()
        
        // Delete the temporary file
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        currentRecordingURL = nil
    }
    
    // MARK: - Playback
    
    func playAudio(from url: URL) throws {
        // Stop any existing playback
        stopPlayback()
        
        // Configure audio session for playback
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        // Create and play audio player
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        
        isPlaying = true
        playbackTime = 0
        
        // Start playback timer
        startPlaybackTimer()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        playbackTime = 0
        stopPlaybackTimer()
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        startPlaybackTimer()
    }
    
    // MARK: - File Management
    
    func saveAudioFile(from tempURL: URL, withName fileName: String) throws -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // Copy file
        try FileManager.default.copyItem(at: tempURL, to: destinationURL)
        
        return fileName
    }
    
    func getAudioURL(for fileName: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func deleteAudioFile(_ fileName: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - Timers
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            self.recordingTime = recorder.currentTime
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.playbackTime = player.currentTime
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorderManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playbackTime = 0
        stopPlaybackTimer()
    }
}

// MARK: - Errors

enum AudioError: LocalizedError {
    case permissionDenied
    case recordingFailed
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access is required to record audio. Please enable it in Settings."
        case .recordingFailed:
            return "Failed to start recording. Please try again."
        case .playbackFailed:
            return "Failed to play audio. The file may be corrupted."
        }
    }
}
