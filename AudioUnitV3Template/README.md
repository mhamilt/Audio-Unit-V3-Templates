# AudioUnit V3 Template Basic

## Overview
This is a bare bones version of a template for creating Audio Unit v3 using C++ for DSP. The idea is to provide just the minimum ino rder to get started creating AU's without having to worry about wading through a nebulous example.

## Code Layout


## Setup
When coding an Audio Units using C++ a couple of changes need to made to the template. The basic setup is ads follows

- Create Cocoa Project
- Use Swift as the language
- - Don’t use storyboards (no reason just prejudice but you can use them later)
- - Don’t select any tests just now, they will clutter things up
- Add new target
- - Select Audio Unit extension
- - No tests
- Rename the audio unit file extension to .mm
- Build the audio unit target and make sure it builds.
