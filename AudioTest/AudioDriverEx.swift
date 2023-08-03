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
    var audioUnitPlayer:AudioUnitPlayer! = nil
    override init()
    {
        super.init()
        //audioEnginePlayer = AudioEnginePlayer.init(frameProvider: audioFileFrameProvider)
        //audioQueuePlayer = AudioQueuePlayer.init(frameProvider:audioFileFrameProvider)
        audioUnitPlayer = AudioUnitPlayer.init(frameProvider:audioFileFrameProvider)
    }
}
