# Audio-Unit-V3-Templates

A collection of templates for creating Audio Unit V3 in Xcode

- [Audio-Unit-V3-Templates](#audio-unit-v3-templates)
  - [About](#about)
    - [Apple Sample Code](#apple-sample-code)
  - [Contributing](#contributing)
  - [Templates](#templates)
    - [AudioUnit V3 Template Basic](#audiounit-v3-template-basic)
    - [AudioUnitV3TemplateWithParameters](#audiounitv3templatewithparameters)
        - [templateAUfxWithParametersAudioUnit.mm](#templateaufxwithparametersaudiounitmm)
        - [AudioUnitViewController.swift](#audiounitviewcontrollerswift)
  - [Troubleshooting](#troubleshooting)
    - [Audio Unit is not visible after building](#audio-unit-is-not-visible-after-building)
    - [Build Errors](#build-errors)
    - [How do I install once I have built the AUv3?](#how-do-i-install-once-i-have-built-the-auv3)
      - [Is there a nicer way to install it?](#is-there-a-nicer-way-to-install-it)
      - [What can I do with my `appex` file?](#what-can-i-do-with-my-appex-file)
  - [Links](#links)
    - [References](#references)
    - [Github Repositories](#github-repositories)

## About

This repository aims to collect together templates for creating Audio Unit v3 Plug-ins.
[Apple's API](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioUnitProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40003278), though powerful, is [nebulous](https://developer.apple.com/documentation/audiotoolbox/incorporating_audio_effects_and_instruments) at best and for the novice DSP engineer it is a bit much to take on. [Apple's sample code](https://developer.apple.com/library/archive/samplecode/sc2195/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013969) and [tutorial](https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects#//apple_ref/doc/uid/TP40016185) left me wanting, so here are a couple of complete Xcode projects to help you get started.

Each template listed will gradually include greater and greater complexity. A `README` can be found in each template folder
but here is a rough guide to get you started.

### Apple Sample Code

To save time traipsing around the [Apple Sample Code Archive](https://developer.apple.com/library/archive/navigation/), here are the links too available sample code for AUv2 and AUv3 code.

- [Creating Custom Audio Effects](https://developer.apple.com/documentation/audiotoolbox/creating_custom_audio_effects?language=objc): AUv3 and macOS 10.15 only. An entirely swift approach.

- [AurioTouch](https://developer.apple.com/library/archive/samplecode/aurioTouch/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007770)
- [Audio Unit Examples (AudioUnit Effect, Generator, Instrument, MIDI Processor and Offline)](https://developer.apple.com/library/archive/samplecode/sc2195/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013969)
- [MatrixMixerTest](https://developer.apple.com/library/archive/samplecode/MatrixMixerTest/Introduction/Intro.html#//apple_ref/doc/uid/DTS40008645)
- [Inter-App Audio Examples](https://developer.apple.com/library/archive/samplecode/InterAppAudioSuite/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013418)

## Contributing

[See Contributing documentation](./CONTRIBUTING.md)

## Templates

### AudioUnit V3 Template Basic

A bare bones template: Audio comes in, Audio Goes out. The DSP kernel is where you will want to focus your attention.
The process method of the DSPKernel class is where the sample by sample processing takes place `(DSPKernel.hpp line 54)`.
You can ignore everything else for now

### AudioUnitV3TemplateWithParameters

Exactly as it says, this is a template that includes a GUI slider object and a gain parameter. Adding in more should be a
simple case of replicating the process of initiating and single parameter. There are some extra classes to pay attention to
in this template

##### templateAUfxWithParametersAudioUnit.mm

This objective C class is what communicates with the DAW environment. The `initWithComponentDescription` method is where
the pointers to parameter values are set. `Line 80` is a good place to start. There are a lot of pointers flying around
which does not help in comprehending the logic.

##### AudioUnitViewController.swift

This file is where you should head for any GUI work. GUI Elements (or "Views" in Apple parlance) can be added via the AudioUnitViewController.xib file. It is highly recommended you start off with a simple Swift based GUI project before delving into this. There are enough headaches to be had in Xcode and Swift without adding in a whole audio processing framework on top.

## Troubleshooting

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

AUv3s are a part of the PluginKit Eco system and information about it is [pretty thin on the ground](https://developer.apple.com/search/?q=pluginkit&type=Documentation). Basically you will need to run your `.app` with the embedded `.appex` _before_ it is registered by PluginKit. You can check your app is registered by

- Running `auval -a` in Terminal and looking for your plugin. `auval -a | grep FOUR_CHARACTER_MANU_CODE` can also help for big lists
- Running `pluginkit -m` in Terminal and looking for your `.appex`'s bundle identifier

#### Is there a nicer way to install it?

Not really, run the `.app` and your done. PluginKit applies to any embedded `.appex` so this method of installation makes sense for those, but is perhaps a little unusual to what audio plug-in users expect.

#### What can I do with my `appex` file?

Not much, your app needs _something_ to embed in the first place. You can always import it into another xcode project. By itself, the appex is useless and you need to embed it in an app.

### Building AUv3s with JUCE

Using JUCE to make an AUv3? [See my post on Troubleshooting AUv3s on the Juce forums](https://forum.juce.com/t/help-my-audio-unit-version-3-auv3-is-not-working/45860).

***

## Links

### References

Here are a couple of links to check out along your AUv3 travels

- [Audio Units (AUv3) MIDI extension – Part 2: C++](http://www.rockhoppertech.com/blog/audio-units-auv3-midi-extension-part-2-c/)
- [Mixing Objective-C, C++ and Objective-C++: an Updated Summary](http://philjordan.eu/article/mixing-objective-c-c++-and-objective-c++)
- [Brain Dump: v3 Audio Units](http://subfurther.com/blog/2017/04/28/brain-dump-v3-audio-units/)

Suggestions are welcome for other helpful articles.

### Github Repositories

Here is a selection of GitHub Repos that I found useful when making these templates.

- [genedelisa/AUParamsApp](https://github.com/genedelisa/AUParamsApp)
- [ring-modulator-v3audiounit](https://github.com/invalidstream/ring-modulator-v3audiounit)
- [FredAntonCorvest/Common-AudioUnit-V3](https://github.com/FredAntonCorvest/Common-AudioUnit-V3)

You can also search GitHub by tag, so have a look at [#auv3](https://github.com/topics/auv3), [#audio-units](https://github.com/topics/audio-units), [#audio-unit](https://github.com/topics/audio-unit), [#audiounit](https://github.com/topics/audiounit) for more examples.
