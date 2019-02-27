/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller for the FilterDemo audio unit. Manages the interactions between a FilterView and the audio unit's parameters.
 */

#ifndef FilterDemoViewController_h
#define FilterDemoViewController_h

#import <CoreAudioKit/AUViewController.h>

@class AUv3FilterDemo;

@interface FilterDemoViewController : AUViewController

@property (nonatomic)AUv3FilterDemo *audioUnit;

@end

#endif /* FilterDemoViewController_h */


