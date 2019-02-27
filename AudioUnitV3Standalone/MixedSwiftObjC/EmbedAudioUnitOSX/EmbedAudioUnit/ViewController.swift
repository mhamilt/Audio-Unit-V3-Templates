//
//  ViewController.swift
//  ImbedAudioUnit
//
//  Created by mhamilt7 on 19/02/2019.
//  Copyright © 2019 mhamilt7. All rights reserved.
//
//==============================================================================
import Foundation
import Cocoa
import CoreAudioKit
import AVFoundation
//==============================================================================
class ViewController: NSViewController, NSWindowDelegate
{
    //==========================================================================
    @IBOutlet var containerView: NSView!
    //==========================================================================
    private var auV3ViewController: FilterDemoViewController?
    private var playEngine: SimplePlayEngine?
    private var cutoffParameter: AUParameter?
    private var resonanceParameter: AUParameter?
    private var parameterObserverToken: AUParameterObserverToken?
    private var factoryPresets: [AUAudioUnitPreset] = []
    //==========================================================================
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // preferredContentSize = NSSize(width: 400, height: 280)
        //----------------------------------------------------------------------        
        embedPlugInView()
        //----------------------------------------------------------------------
        let desc = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                             componentSubType: 0,
                                             componentManufacturer: 0,
                                             componentFlags: 0,
                                             componentFlagsMask: 0)
        
        AUAudioUnit.registerSubclass(AUv3FilterDemo.self,
                                     as: desc,
                                     name: "Demo: Local AUv3",
                                     version: UINT32_MAX)
        //----------------------------------------------------------------------
        playEngine = SimplePlayEngine(componentType: desc.componentType,
                                      componentsFoundCallback: nil)
        //----------------------------------------------------------------------
        // this is hacky, chooses the first effect which should be the imbedded audio unit.
        let effect = AVAudioUnitComponentManager.shared().components(matching: desc)[0]
        //----------------------------------------------------------------------
        playEngine?.selectAudioUnitComponent(effect,
                                             completionHandler:{ self.connectXibControls() })
        playEngine?.togglePlay()
    }
    //==========================================================================
    override var representedObject: Any?
        {
        didSet
        {
            
        }
    }
    //==========================================================================
    func windowWillClose(_ notification: Notification)
    {
        auV3ViewController = nil
    }
    //==========================================================================
    func embedPlugInView()
    {    
        let builtInPlugInURL: URL? = Bundle.main.builtInPlugInsURL
        let pluginURL: URL? = builtInPlugInURL?.appendingPathComponent("FilterDemoAppExtension.appex")
        var appExtensionBundle: Bundle? = nil
        if let pluginURL = pluginURL
        {
            appExtensionBundle = Bundle(url: pluginURL)
        }
        
        auV3ViewController = FilterDemoViewController(
            nibName: NSNib.Name(rawValue: "FilterDemoViewController"),
            bundle: appExtensionBundle)
        
        let view: NSView? = auV3ViewController?.view
        
        if let view = view
        {
            containerView.addSubview(view)
        }
    }
    //==========================================================================
    func fourCharCode(from string : String) -> FourCharCode
    {
        return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
    //==========================================================================
    func connectXibControls()
    {
        auV3ViewController!.audioUnit = playEngine!.testAudioUnit as! AUv3FilterDemo
    }
}

