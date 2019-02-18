//==============================================================================
//
//  ControlKnob.swift
//  cocoaXibs
//
//  Created by mhamilt7 on 31/05/2018.
//  Copyright © 2018 mhamilt7. All rights reserved.
//
//==============================================================================

import Cocoa
import AppKit
import QuartzCore

//==============================================================================
/// Custom UI Slider for PA plugins

class PAKnob: NSView
{
    //==========================================================================
    // Class Members
    @IBInspectable var suffix: String = ""
    @IBInspectable var maxValue: Float = 10
    @IBInspectable var minValue: Float = 0
    @IBInspectable var value: Float = 0
    @IBInspectable var decPlace: Int = 1
    
    var range: Float = 0
    
    //==========================================================================
    // PA Colours
    let paBlack = CGColor(red: CGFloat(0x0e)/255, green: CGFloat(0x0e)/255, blue: CGFloat(0x10)/255, alpha: 1.0)
    let paBackgrondGrey = CGColor(red: CGFloat(0x2c)/255, green: CGFloat(0x2c)/255, blue: CGFloat(0x2c)/255, alpha: 1.0);
    let paKnobRimColour = CGColor(red: CGFloat(0x59)/255, green: CGFloat(0x59)/255, blue: CGFloat(0x59)/255, alpha: 1.0);
    let paKnobTopColour = CGColor(red: CGFloat(0x3f)/255, green: CGFloat(0x3f)/255, blue: CGFloat(0x3f)/255, alpha: 1.0);
    let paTextColour    = CGColor(red: CGFloat(0xd8)/255, green: CGFloat(0xd9)/255, blue: CGFloat(0xd9)/255, alpha: 1.0);
    let paValueBlue     = CGColor(red: CGFloat(0x6e)/255, green: CGFloat(0xA9)/255, blue: CGFloat(0xff)/255, alpha: 1.0);
    
    //==========================================================================
    // Graphics Parameters
    let trackLayer = CAShapeLayer()
    let dial = CAShapeLayer()
    let label = NSTextField(labelWithString: "")
    var dialView = NSView()
    private var dialRadius = CGFloat(0)
    private var dialLength = CGFloat(0)
    private var angle: CGFloat = 0
    private var tx: CGFloat = 0
    private var ty: CGFloat = 0
    var transx: CGFloat
    {
        get{return tx}
        set
        {
            tx = newValue
            updateRotation(angle, newValue, ty)
        }
    }
    var transy: CGFloat
    {
        get{return ty}
        set
        {
            ty = newValue
            updateRotation(angle, tx, newValue)
        }
    }
    var rot: CGFloat
    {
        get{return angle}
        set
        {
            angle = newValue
            updateRotation(newValue, tx, ty)
        }
    }
    //==========================================================================
    // Class Functions
    
    //--------------------------------------------------------------------------
    // initialisers
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    public init(frame: CGRect, initValue: Float)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setup()
    }
    
    //--------------------------------------------------------------------------
    override func draw(_ rect: NSRect)
    {
        super.draw(rect)
        range = maxValue - minValue
        //======================================================================
        let context = NSGraphicsContext.current?.cgContext
        //======================================================================
        let width  = rect.width
        let knobCentre = CGPoint(x: rect.midX, y: rect.midY)
        let knobStartAngle: CGFloat  = -3 * CGFloat.pi * 0.25;
        let knobEndAngle: CGFloat =  -CGFloat.pi * 0.25
        let lineWidth: CGFloat = 0.035 * rect.height * 0.5;
        let radius = (rect.height * 0.5) - lineWidth ;
        //======================================================================
        let backgroundArc = CGMutablePath()
        backgroundArc.addArc(center: knobCentre ,
                             radius: radius,
                             startAngle: knobStartAngle,
                             endAngle: knobEndAngle,
                             clockwise: true)
        context?.addPath(backgroundArc)
        context?.setStrokeColor(paBlack)
        context?.setLineWidth(lineWidth)
        context?.strokePath()
        drawKnob(diameter: width, context: context)
        
        //======================================================================
        // Set the track layer
        let trackPath = CGMutablePath()
        trackPath.addArc(center: knobCentre ,
                         radius: radius,
                         startAngle: knobStartAngle,
                         endAngle: knobEndAngle,
                         clockwise: true)
        
        trackLayer.path = trackPath
        trackLayer.strokeColor = paValueBlue
        trackLayer.lineWidth = lineWidth * 1.3
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.strokeStart = 0.0
        trackLayer.strokeEnd = 0.7
        layer?.addSublayer(trackLayer)
        //======================================================================
        updateKnob()
        
        let rect = bounds;
        let fontSize = CGFloat(0.14*rect.width)
        label.font! = NSFont.systemFont(ofSize: fontSize)
        updateLabel()
        let tWidth = label.font!.pointSize * CGFloat(label.stringValue.count)
        let textMidX = rect.midX - (tWidth * 0.3)
        let textMidY = rect.midY - (label.frame.height * 0.44)
        
        label.frame = NSRect(x: textMidX, y: textMidY, width: label.frame.width, height: label.frame.height)
        label.textColor = NSColor(cgColor: paTextColour)
        addSubview(label)
    }
    
    //--------------------------------------------------------------------------
    /// setup class members and behaviour
    func setup()
    {
        self.dialView.frame = bounds
        //======================================================================
        
        
        //======================================================================
        addGestureRecognizer(
            NSRotationGestureRecognizer(
                target: self,
                action: #selector(handleRotationGesture
                )
            )
        )
        //======================================================================
        addGestureRecognizer(
            NSPanGestureRecognizer(
                target: self,
                action: #selector(handleDrag
                )
            )
        )
    }
    
    //--------------------------------------------------------------------------
    
    @objc func handleRotationGesture(_ gestureRecognizer: NSRotationGestureRecognizer)
    {
        let x = Float(gestureRecognizer.rotationInDegrees) * -0.001
        setParamValue(value + x)
    }
    
    @objc func handleDrag(_ gestureRecognizer: NSPanGestureRecognizer)
    {
        let y: Float = Float(gestureRecognizer.velocity(in: self).y)
        setParamValue(value + y * 0.0002)
    }
    
    override open func scrollWheel(with event: NSEvent)
    {
        let range = Float(maxValue - minValue)
        var delta = Float(0)
        delta = Float(event.deltaY)
        let increment = range * delta * 0.005
        setParamValue(value + increment)
    }
    
    //--------------------------------------------------------------------------
    /// UNDER CONSTRUCTION: set parameters and organise threads for graphics
    /// to update
    /// - Parameters:
    ///   - value: <#value description#>
    ///   - animated: <#animated description#>
    open func setParamValue(_ value: Float)
    {
        if(value != self.value)
        {
            self.value = min(maxValue, max(minValue, value))
            //            if let action = self.action
            //            {
            //                NSApp.sendAction(action, to: self.target, from: self)
            //            }
            DispatchQueue.main.async{self.updateKnob()} // basically, update graphics on backburner
            updateKnob()
        }
    }
    
    //--------------------------------------------------------------------------
    /// update all graphics elements
    func updateKnob() -> Void
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let normValue = CGFloat((value-minValue)/range)
        trackLayer.strokeEnd = normValue
        CATransaction.commit()
        updateDial(normValue)
        updateLabel()
    }
    //--------------------------------------------------------------------------
    func drawEllipse(rect: CGRect, context: CGContext?, colour: CGColor)
    {
        let ellipse = CGPath(ellipseIn: rect, transform: nil)
        context?.addPath(ellipse)
        context?.setFillColor(colour)
        context?.fillPath()
        context?.strokePath()
    }
    
    //==========================================================================
    
    func drawKnob(diameter: CGFloat, context: CGContext?)
    {
        //======================================================================
        let baseRatio = CGFloat(0.75);
        let baseDiam = baseRatio * diameter;
        let baseOffSetX = (diameter - (baseDiam)) * 0.5;
        let baseOffSetY = (diameter - (baseDiam)) * 0.5;
        let baseRect = CGRect(x: baseOffSetX, y: baseOffSetY, width: baseDiam, height: baseDiam)
        drawEllipse(rect: baseRect, context: context, colour: paBlack)
        //======================================================================
        let sideRatio = CGFloat(240.0/250.0);
        let sideDiam = sideRatio*baseDiam;
        let sideOffSetX = baseOffSetX+(baseDiam - (sideDiam)) * 0.5;
        let sideOffSetY = baseOffSetY+(baseDiam - (sideDiam)) * 0.5;
        let sideRect = CGRect(x: sideOffSetX, y: sideOffSetY, width: sideDiam, height: sideDiam)
        drawEllipse(rect: sideRect, context: context, colour: paBackgrondGrey)
        //======================================================================
        let rimRatio = CGFloat(218.0/250.0);
        let rimDiam = rimRatio*baseDiam;
        let rimOffSetX = baseOffSetX + (baseDiam - (rimDiam)) * 0.5;
        let rimOffSetY = baseOffSetY + (baseDiam - (rimDiam)) * 0.5;
        let rimRect = CGRect(x: rimOffSetX, y: rimOffSetY, width: rimDiam, height: rimDiam)
        drawEllipse(rect: rimRect, context: context, colour: paKnobRimColour)
        context?.setShadow(offset: CGSize(width: diameter*0.045, height: -diameter*0.12), blur: 2)
        //======================================================================
        let topRatio:CGFloat = CGFloat(212.0/250.0);
        let topDiam:CGFloat = topRatio*baseDiam;
        let topOffSetX:CGFloat = baseOffSetX + (baseDiam - (topDiam)) * 0.5;
        let topOffSetY:CGFloat = baseOffSetY + (baseDiam - (topDiam)) * 0.5;
        let topRect = CGRect(x: topOffSetX, y: topOffSetY, width: topDiam, height: topDiam)
        drawEllipse(rect: topRect, context: context, colour: paKnobTopColour)
        
        //======================================================================
        let dialPath = CGMutablePath()
        let dialWidth = 0.035 * topDiam * 0.5
        let dialAngle: CGFloat = 5 * CGFloat.pi * 0.25
        dialRadius = topDiam * 0.5;
        dialLength = dialRadius - (topDiam * 0.15);
        let centre = CGPoint(x: bounds.midX, y: bounds.midX)
        let dialStart = CGPoint(x: (cos(dialAngle) * dialRadius) + centre.x,
                                y: (sin(dialAngle) * dialRadius) + centre.y)
        let dialEnd = CGPoint(x: (cos(dialAngle) * dialLength) + centre.x,
                              y: (sin(dialAngle) * dialLength) + centre.y)
        dialPath.addLines(between: [dialStart, dialEnd])
        
        dial.lineWidth = dialWidth
        dial.path = dialPath
        dial.strokeColor = paValueBlue
        layer?.addSublayer(dial)
        //======================================================================
    }
    
    //==========================================================================
    
    func updateRotation(_ angle: CGFloat,_ x:CGFloat,_ y:CGFloat)
    {
        let dialPath = CGMutablePath()
        let dialPos:   CGFloat = angle
        let dialAngle: CGFloat = (5 * CGFloat.pi * 0.25) - dialPos * (6 * CGFloat.pi * 0.25)
        let centre = CGPoint(x: bounds.midX, y: bounds.midX)
        let dialStart = CGPoint(x: (cos(dialAngle) * dialRadius) + centre.x,
                                y: (sin(dialAngle) * dialRadius) + centre.y)
        let dialEnd = CGPoint(x: (cos(dialAngle) * dialLength) + centre.x,
                              y: (sin(dialAngle) * dialLength) + centre.y)
        
        dialPath.addLines(between: [dialStart, dialEnd])
        dial.path = dialPath
        dial.needsDisplay()
    }
    
    //==========================================================================
    /// update the dial layer to the new knob position
    ///
    /// - Parameter value: normalised value between 0 and 1
    func updateDial(_ value: CGFloat)
    {
        let dialAngle: CGFloat = (5 * CGFloat.pi * 0.25) - value * (6 * CGFloat.pi * 0.25)
        let dialPath = CGMutablePath()
        let centre = CGPoint(x: bounds.midX, y: bounds.midX)
        let dialStart = CGPoint(x: (cos(dialAngle) * dialRadius) + centre.x,
                                y: (sin(dialAngle) * dialRadius) + centre.y)
        let dialEnd = CGPoint(x: (cos(dialAngle) * dialLength) + centre.x,
                              y: (sin(dialAngle) * dialLength) + centre.y)
        dialPath.addLines(between: [dialStart, dialEnd])
        dial.path = dialPath
        dial.needsDisplay()
    }
    
    //==========================================================================
    
    func updateLabel()
    {
        let dec = "%.\(decPlace)f"
        let labelString = (NSString(format: dec as NSString, value) as String) + suffix
        label.stringValue = labelString
        label.sizeToFit()
    }
}

//==============================================================================
// EOF

