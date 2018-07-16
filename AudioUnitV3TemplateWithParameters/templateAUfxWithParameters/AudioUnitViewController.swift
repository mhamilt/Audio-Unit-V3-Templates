//
//  AudioUnitViewController.swift
//  templateAUfxWithParameters
//
//  Created by mhamilt7 on 11/07/2018.
//  Copyright © 2018 mhamilt7. All rights reserved.
//
//==============================================================================
import CoreAudioKit
//==============================================================================
public class AudioUnitViewController: AUViewController, AUAudioUnitFactory
{
    //==========================================================================
    @IBOutlet var gainSlider: NSSlider!
    //==========================================================================
    var audioUnit: AUAudioUnit?
    //==========================================================================
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        NSLog("Finished viewDidLoad()", NSNull())
        if audioUnit == nil
        {
            return
        }
    }
    
    public override func awakeFromNib()
    {
            NSLog("Awake From NIB", NSNull())
    }
    
    //==========================================================================
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit
    {
        NSLog("Create Audio Unit", NSNull())
        audioUnit = try templateAUfxWithParametersAudioUnit(componentDescription: componentDescription, options: [])
        return audioUnit!
    }
    //==========================================================================

    @IBAction func handleGainSliderValueChanged(_ sender: NSSlider)
    {
        guard let modulatorUnit = audioUnit as? templateAUfxWithParametersAudioUnit else {return}
        guard let gainParameter = modulatorUnit.parameterTree?.parameter(withAddress: myParam1) else { return }
        gainParameter.setValue(sender.floatValue, originator: nil)
    }
    //==========================================================================
}
