
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `FilterDemoViewController` is the app extension's principal class, responsible for creating both the audio unit and its view.
 */

#import <CoreAudioKit/AUViewController.h>
#import <FilterDemoFramework/FilterDemoFramework.h>

@interface FilterDemoViewController (AUAudioUnitFactory) <AUAudioUnitFactory>

@end

