/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `FilterDemoViewController` is the app extension's principal class, responsible for creating both the audio unit and its view.
 */

#import "FilterDemoViewController+AUAudioUnitFactory.h"

@implementation FilterDemoViewController (AUAudioUnitFactory)

- (AUv3FilterDemo *) createAudioUnitWithComponentDescription:(AudioComponentDescription) desc error:(NSError **)error
{
    self.audioUnit = [[AUv3FilterDemo alloc] initWithComponentDescription:desc error:error];
    return self.audioUnit;
}

@end
