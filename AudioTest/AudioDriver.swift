//
//  AudioDriver.swift
//  NES_EMU
//
//  Created by mio on 2023/7/24.
//

import Foundation
import AVFAudio

class AudioBufferProvider:NSObject
{
    var m_buffer: [Float32] = []
    var m_bufferToPlay: [Float32] = []
    var m_unitSize:Int = 0
    var m_sampleRate:Double = 0
    
    override init()
    {
        super.init()
        openFile()
    }
    
    var m_audioFile:AVAudioFile?
    var m_fileUrl:URL?
    
    func getNextBuffer()->AVAudioPCMBuffer?
    {
        //var audioPCMBuffer:AVAudioPCMBuffer?
        
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(48000), channels: 2, interleaved: false)
        
        let frameLength = AVAudioFrameCount(48000)/10
        //audioPCMBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat!, frameCapacity: AVAudioFrameCount(frameLength))!
        
        _ = AVAudioFrameCount(UInt32(m_audioFile!.length))
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat!, frameCapacity: frameLength)
        
        do{
            try m_audioFile?.read(into: audioBuffer!, frameCount: frameLength)
        }
        catch
        {
            print(error)
        }
        
        
        return audioBuffer
    }
    
    func openFile()
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL

        let m_fileUrl = documentsUrl.appendingPathComponent("sample4.aac")
        m_audioFile = try! AVAudioFile.init(forReading: m_fileUrl!)
    }
    
    func setUnitSize(_ unitCount:Double)
    {
        m_unitSize = Int(unitCount)
    }
    
    func setSampleRate(_ sampleRate:Double)
    {
        m_sampleRate = sampleRate
    }
    
    private let lock = NSLock()
    private let lockTake = NSLock()
    
    public func enqueue(input:Float32)
    {
        lock.lock()
        
        //print(String(input))
        //m_buffer.append(0.1)
        
        m_buffer.append(input)
        
        //feedCount += 1
        
        if(feedCount >= 44100)
        {
            //print("lostRate: "+String(lostCount) + "/" + String(feedCount))
            
            //feedCount = 0
            //lostCount = 0
        }
        
        if(m_buffer.count >= m_unitSize)
        {
            fillInBuffer(buffer: m_buffer)
            m_buffer.removeAll()
        }
        
        
        lock.unlock()
    }
    
    
    var audioBuffer0:AVAudioPCMBuffer?
    var audioBuffer1:AVAudioPCMBuffer?
    var m_curIndex = -1
    
    var feedCount = 0
    var lostCount = 0
    var lostRate = 0.0
    private let lockFillBuffer = NSLock()
    func fillInBuffer(buffer:[Float32])
    {
        lockFillBuffer.lock()
        if(m_curIndex == -1 || m_curIndex == 0)
        {
            audioBuffer0 = readAudioBuffer(buffer: buffer, sampleRate: m_sampleRate)
            /*
            if((audioBuffer0) != nil)
            {
                try? m_audioFile?.write(from: audioBuffer0!)
            }
            */
        }
        else if(m_curIndex == 1)
        {
            audioBuffer1 = readAudioBuffer(buffer: buffer, sampleRate: m_sampleRate)
            /*
            if((audioBuffer1) != nil)
            {
                try? m_audioFile?.write(from: audioBuffer1!)
            }
             */
        }
        
        m_curIndex = m_curIndex + 1
        if(m_curIndex > 1)
        {
            m_curIndex = 0
        }
        lockFillBuffer.unlock()
    }
    
    func getNextBuffer123()->AVAudioPCMBuffer?
    {
        var out:AVAudioPCMBuffer? = nil
        if(m_curIndex == -1)
        {
            NSLog("get--nil")
            return nil
        }
        
        lockFillBuffer.lock()
        if(m_curIndex == 0)
        {
            out =  audioBuffer0
            NSLog("get--0")
        }
        else if(m_curIndex == 1)
        {
            out = audioBuffer1
            NSLog("get--1")
        }
        lockFillBuffer.unlock()
        
        
        return out
    }
    
    public func dequeue()->AVAudioPCMBuffer?
    {
        var audioPCMBuffer:AVAudioPCMBuffer?
        //print("dequeue->" + String(m_bufferToPlay.count))
        lockTake.lock()
        if(m_bufferToPlay.count > 0)
        {
            
            audioPCMBuffer = readAudioBuffer(buffer: m_bufferToPlay, sampleRate: m_sampleRate)
            m_bufferToPlay.removeAll()
            //audioPCMBufferLast = audioPCMBuffer
        }
        else
        {
            /*
            if(audioPCMBufferLast != nil)
            {
                lockTake.unlock()
                
                print("==audioPCMBufferLast==")
                return audioPCMBufferLast
            }
             */
        }
        
        lockTake.unlock()
        //print("dequeue->end")
        return audioPCMBuffer
    }
    var m_lastValue:Float32 = 0.0
    func readAudioBuffer(buffer: [Float32],sampleRate:Double)->AVAudioPCMBuffer
    {
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(m_sampleRate), channels: 2, interleaved: false)
        
        _ = buffer.count
        let frameLengthFake = buffer.count
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat!, frameCapacity: AVAudioFrameCount(frameLengthFake))!

        
        var buf = buffer
        for _ in 0...(buffer.count-1)
        {
            buf.append(0)
        }
        
        memcpy(audioBuffer.mutableAudioBufferList.pointee.mBuffers.mData, &buf, MemoryLayout<Float32>.stride * frameLengthFake)

        audioBuffer.frameLength = AVAudioFrameCount(frameLengthFake)
        return audioBuffer
    }
}

class AudioDriver:NSObject {
    var audioBufferProvider:AudioBufferProvider = AudioBufferProvider()
    //OSX
    //var audioSession: AVCaptureSession = AVCaptureSession()
    var engine:AVAudioEngine!
    var playerNode:AVAudioPlayerNode!
    var audioBuffer:AVAudioPCMBuffer!
    
    public func enqueue(input:Float32)
    {
        audioBufferProvider.enqueue(input: input)
    }
    
    override init()
    {
        super.init()
        let unitSize = self.GetSampleRate()/60
        self.audioBufferProvider.setUnitSize(unitSize)
        
        self.audioBufferProvider.setSampleRate(self.GetSampleRate())
        do {
            engine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            let sampleRate = 48000//self.GetSampleRate()
            let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(sampleRate), channels: 2, interleaved: false)!
            //circularBuffer = TPCircularBuffer()
            //engine.isAutoShutdownEnabled = false
        
            playerNode.volume = 0.4
            engine.mainMixerNode.volume = 0.4
            engine.attach(playerNode)
            
            //engine.connect(playerNode, to: engine.mainMixerNode, fromBus: 0, toBus: 0, format: outputFormat)
        
            engine.connect(playerNode, to: engine.outputNode, format: outputFormat)
            //engine.connect(playerNode, to: engine.mainMixerNode, fromBus:0 toBus:0 format:nil)
            //engine.connect(playerNode, to: engine.outputNode, format: outputFormat)
            //engine.prepare()
            
            do {
                try engine.start()
            } catch {
                print("error")
            }
            self.playerNode.play()
            
            self.startPlay()
        }
    }
    
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
        let audioBuffer = self.audioBufferProvider.getNextBuffer()
        if(audioBuffer != nil)
        {
            //self.playerNode.scheduleBuffer(<#T##buffer: AVAudioPCMBuffer##AVAudioPCMBuffer#>) {
                
            //}
            //NSLog("get-play")
            self.playerNode.scheduleBuffer(audioBuffer!) {
                //NSLog("get-end")
                self.enqueueBuffer()
            }
            
            //self.isBusy = true
        }
    }
    
    
    func GetSampleRate()->Double
    {
        return 44100
    }
}
