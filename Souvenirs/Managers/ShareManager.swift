//
//  ShareManager.swift
//  Souvenirs
//
//  Created by Jean Martin on 05/12/2025.
//

import SwiftUI
import UIKit

class ShareManager {
    
    static let shared = ShareManager()
    
    private init() {}
    
    //MARK: SHARE TEXT
    
    func shareMemoryAsText(memory: Memory) {
        let text = formatMemoryAsText(memory)
        share(items: [text])
    }
    //
    private func formatMemoryAsText(_ memory: Memory) ->String {
        var text = "📍 \(memory.title)\n\n"
        text += "Location: \(memory.locationName)\n"
        text += "Date: \(formatDate(memory.createdDate))\n\n"
        text += memory.content
        text += "\n\n❤️ \(memory.likesCount) likes"
        
        if memory.hasAudio {
            text += "\n🎤 Includes voice recording"
            
        }//if end
        
        return text
        
    }//FUNC END
    
    //MARK: SHARE IMAGE
    func shareMemoryAsImage(memory: Memory) {
        let renderer = ImageRenderer(content: MemoryCardView(memory: memory))
        renderer.scale = 0.3 //high resolution
        
        if let image = renderer.uiImage {
            share(items: [image])
        } //if end
        
    }// func end
    
    //MARK: GENERIC SHARE FUNCTION
    func share (items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
                let rootVC = window.rootViewController else {
            return
        } //guard let end
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        //for ipad set popover source
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
            
            
        } //if let end
        rootVC.present(activityVC, animated: true)
        
        
    }//func 3 end
    
    //MARK: HELPERS
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
        
        
    }//func end
    
    
} //class end
