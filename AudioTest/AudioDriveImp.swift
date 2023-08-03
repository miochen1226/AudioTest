//
//  AudioDriveImp.swift
//  AudioTest
//
//  Created by mio on 2023/8/2.
//

import Foundation

class FrameObj:NSObject
{
    var buffer:UnsafeMutablePointer<UInt8>?
    var byteCount:UInt32 = 0
    
    deinit
    {
        buffer?.deallocate()
    }
}

protocol FrameProvider
{
    func getNextFrame()->FrameObj
}

protocol AudioDriveImp
{
    var m_frameProvider:FrameProvider? { get set }
    init(frameProvider:FrameProvider)
}
