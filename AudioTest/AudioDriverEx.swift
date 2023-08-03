//
//  AudioDriver.swift
//  NES_EMU
//
//  Created by mio on 2023/7/24.
//

import Foundation
import AVFAudio
import AVFoundation

class AudioDriverEx:NSObject {
    let audioFileFrameProvider = AudioFileFrameProvider()
    var audioQueuePlayer:AudioQueuePlayer! = nil
    var audioEnginePlayer:AudioEnginePlayer! = nil
    
    override init()
    {
        super.init()
        //audioEnginePlayer = AudioEnginePlayer.init(frameProvider: audioFileFrameProvider)
        audioQueuePlayer = AudioQueuePlayer.init(frameProvider:audioFileFrameProvider)//AudioQueuePlayer(frameProvider: audioFileFrameProvider)
        
    }
    
    

    
    //func processOutputBuffer(buffer:AudioQueueBufferRef,)
    
    let serialQueue = DispatchQueue(label: "SerialQueueAudio")
    
    var m_wantQuit = false
    func stop()
    {
        m_wantQuit = true
    }
    
    let sleepTime:UInt32 = 1000000/60
    
    var isBusy = false
    func startPlay()
    {
        enqueueBuffer()
        /*
        serialQueue.async {
            while (self.m_wantQuit == false)
            {
                usleep(self.sleepTime)
                if(self.isBusy)
                {
                    return
                }
                let audioBuffer = self.audioBufferProvider.getNextBuffer()
                if(audioBuffer != nil)
                {
                    //self.playerNode.scheduleBuffer(<#T##buffer: AVAudioPCMBuffer##AVAudioPCMBuffer#>) {
                        
                    //}
                    NSLog("get-play")
                    self.playerNode.scheduleBuffer(audioBuffer!, at: nil, options: [.interrupts]){
                        NSLog("get-end")
                    }
                    //self.isBusy = true
                }
            }
        }*/
    }
    
    func enqueueBuffer()
    {
        
    }
    
    
    func GetSampleRate()->Double
    {
        return 44100
    }
}
extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }
