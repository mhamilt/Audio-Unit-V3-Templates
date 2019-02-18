# Audio-Unit-V3-Templates
A collection of templates for creating Audio Unit V3 in Xcode

## About
This repository aims to collect together templates for creating Audio Unit v3 Plug-ins.
Apple's API, though powerful, is nebulous at best and for the novice DSP engineer it is a bit much to take on.

Each template listed will gradually include greater and greater complexity. A README can be found in each template folder
but here is a rough guide to get you started.

## AudioUnit V3 Template Basic
A bare bones template: Audio comes in, Audio Goes out. The DSP kernel is where you will want to focus your attention.
The process method of the DSPKernel class is where the sample by sample processing takes place `(DSPKernel.hpp line 54)`.
You can ignore everything else for now


## AudioUnitV3TemplateWithParameters
Exactly as it says, this is a template that includes a GUI slider object and a gain parameter. Adding in more should be a
simple case of replicating the process of initiating and single parameter. There are some extra classes to pay attention to
in this template

#### templateAUfxWithParametersAudioUnit.mm
This objective C class is what communicates with the DAW environment. The `initWithComponentDescription` method is where
the pointers to parameter values are set. `Line 80` is a good place to start. There are a lot of pointers flying around
which does not help in comprehending the logic.

#### AudioUnitViewController.swift
This file is where you should head for any GUI work. GUI Elements (or "Views" in Apple parlance) can be added via the AudioUnitViewController.xib file. It is highly recommended you start off with a simple Swift based GUI project before delving into this. There are enough headaches to be had in Xcode and Swift without adding in a whole audio processing framework on top.

# Troubleshooting
Common issues I have come across when building audio units.
Sanity check with the `auval` terminal command


### Audio Unit is not visible after building
Take a look at the info.plist file, an XML file of info about your Audio Unit
Try changing the 4 letter code. Try altering the manufacturer code as well.

![info.plist](https://github.com/mhamilt/Audio-Unit-V3-Templates/blob/master/images/info.plist.png)

### Build Errors

- `'vector' file not found`
- `""_OBJC_CLASS_$_AVAudioFormat", referenced from:"`
- `"_OBJC_CLASS_$_AVAudioPCMBuffer", referenced from:`
- `linker command failed with exit code 1 (use -v to see invocation)`

Any of the above? Sounds like you have forgotten to link a library, most probably AVFoundation.

![LinkLibrary](https://github.com/mhamilt/Audio-Unit-V3-Templates/blob/master/images/BuildPhaseSetup.png)

or your AudioUnit ObjectiveC++ file has the wrong extension. Change it to `.mm`

![ObjectiveC++ naming](https://github.com/mhamilt/Audio-Unit-V3-Templates/blob/master/images/ObjectiveC++FileNaming.png)

### How do I install once I have built the AUv3?
The AUv3 is an app extension that is part of a larger application. Along with the `.appex` files you should have a `.app` file. Open that on the machine you wish to install and it should register the AUv3.

#### Is there a nicer way to install it?
I am currently looking into cleaner package delivery. Watch this space.

# References
Here are a couple of links to check out along your AUv3 travels

http://www.rockhoppertech.com/blog/audio-units-auv3-midi-extension-part-2-c/

http://philjordan.eu/article/mixing-objective-c-c++-and-objective-c++

http://subfurther.com/blog/2017/04/28/brain-dump-v3-audio-units/

# Github Repositories

Here is a selection of GitHub Repos that I found useful when making these templates

https://github.com/genedelisa/AUParamsApp

https://github.com/invalidstream/ring-modulator-v3audiounit

https://github.com/FredAntonCorvest/Common-AudioUnit-V3
