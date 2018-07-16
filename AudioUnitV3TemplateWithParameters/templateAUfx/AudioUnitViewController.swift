//
//  AudioUnitViewController.swift
//  templateAUfx
//
//  Created by mhamilt7 on 10/07/2018.
//  Copyright © 2018 mhamilt7. All rights reserved.
//
//==============================================================================
import CoreAudioKit
//==============================================================================
public class AudioUnitViewController: AUViewController, AUAudioUnitFactory
{
    //==========================================================================
    var audioUnit: AUAudioUnit?
    //==========================================================================
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        //----------------------------------------------------------------------
        // Set Background Colour
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        //----------------------------------------------------------------------
        if audioUnit == nil
        {
            NSLog("AUDIO UNIT = NIL", NSNull())
            return
        }
        NSLog("AUDIO UNIT Exists", NSNull())
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    //==========================================================================
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit
    {
        NSLog("Create Audio Unit", NSNull())
        audioUnit = try templateAUfxAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    //==========================================================================
}
