//
//  AudioFileFrameProvider.swift
//  AudioTest
//
//  Created by mio on 2023/8/2.
//

import Foundation

class AudioFileFrameProvider:NSObject,FrameProvider
{
    var m_inputStream:InputStream?
    override init()
    {
        super.init()
        let bundleUrl = Bundle.main.url(forResource: "TestData", withExtension: "bundle")
        let fileUrl = bundleUrl!.appendingPathComponent("audio.pcm")
        
        m_inputStream = InputStream(url: fileUrl)
        
        if(m_inputStream == nil)
        {
            print("file open fail")
        }
        
        m_inputStream?.open()
        
    }
    
    func getNextFrame()->FrameObj
    {
        let bufferSize = 44100*4/10
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        let frameObj = FrameObj()
        let readCount = m_inputStream?.read(buffer, maxLength: bufferSize) ?? 0
        
        if(readCount>0)
        {
            frameObj.byteCount = UInt32(readCount)
            frameObj.buffer = buffer
        }
        
        return frameObj
    }
}
