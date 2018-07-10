# AudioUnit V3 Template Basic

## Overview
This is a bare bones version of a template for creating Audio Unit v3 using C++ for DSP. The idea is to provide just the minimum in order to get started creating AU's without having to worry about wading through a nebulous example from Apple.

## Setup
When coding an Audio Units using C++ a couple of changes need to made to the template. The basic setup is ads follows

- Create Cocoa Project
- Use Swift as the language
  - Don’t use storyboards (no reason just prejudice but you can use them later)
  - Don’t select any tests just now, they will clutter things up
- Add new target
  - Select Audio Unit extension
  - No tests
- Rename the audio unit file extension to .mm
- In the project setup make sure AVFoundation and any other required frameqworks are included in linked libraries
- Build the audio unit target and make sure it builds without error.

## Code Layout

The code has these 3 main elements

- .swift View Controller that is incharge of the GUI
- .h and .mm files for initialising the Audio Unit
- DSPKernel.hpp takes care of rendering audio

With Objective-C++ (i.e. Objective-C and C++ smooshed together) the core DSP needs to be wrapped in a C++ class, hence DSPKernal. This class can be called and structure however you please. It is hopefully presented in such a way that the inner workings are fairly obvious.

If you want to get straight to majking some cool noises, the sample manipulation takes place in the `process()` function and has a `MARK` placed next to it so you can navigate straight to it in Xcode.
