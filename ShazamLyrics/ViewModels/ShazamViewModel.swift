//
//  ShazamViewModel.swift
//  ShazamLyrics
//
//  Created by Enrique Sarmiento on 30/4/24.
//

import Foundation
import ShazamKit
import AVKit
import SwiftUI

class ShazamViewModel: NSObject , ObservableObject {
   @Published var shazamModel = ShazamModel(title: "Pulsa", artist: "Escuchar", album: URL(string: "https://www.google.com"))
   @Published var recording: Bool = false
   
   private var audioEngine = AVAudioEngine()
   private var session = SHSession()
   private var signatureGenerator = SHSignatureGenerator()
   
   override init() {
      super.init()
      session.delegate = self
   }
   
   func startListening(){
      guard !audioEngine.isRunning else {
         audioEngine.stop()
         DispatchQueue.main.async {
            self.recording = true
         }
         return
      }
      
      let audioSession = AVAudioSession.sharedInstance()
      audioSession.requestRecordPermission { granted in
         guard granted else {return}
         
         try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
         let inputNode = self.audioEngine.inputNode
         let recordingFormat = inputNode.outputFormat(forBus: 0)
         
         inputNode.removeTap(onBus: .zero)
         // this is taking advance of the microphone to compare data
         inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.session.matchStreamingBuffer(buffer, at: nil)
         }
         
         self.audioEngine.prepare()
         
         do{
            try self.audioEngine.start()
         }catch let error as NSError{
            print("DEBUG: error al escanear audio", error.localizedDescription)
         }
         
         DispatchQueue.main.async {
            self.recording = true
         }
      
         
      }
      
      
   }
   
   //here we stop listing from audio
   func stop(){
      if audioEngine.isRunning {
         audioEngine.stop()
         DispatchQueue.main.async {
            self.recording = false
         }
      }
   }
}

//this extension help us to get information from shazam to get music info
extension ShazamViewModel: SHSessionDelegate {
   func session(_ session: SHSession, didFind match: SHMatch) {
      let mediaItems = match.mediaItems
      
      if let item = mediaItems.first {
         DispatchQueue.main.async {
            self.shazamModel = ShazamModel(title: item.title, artist: item.artist, album: item.artworkURL)
            
            // when we get the image, we can stop listening.
            if ((self.shazamModel.album?.isFileURL) != nil) {
               self.stop()
            }
         }
      }
   }
}

