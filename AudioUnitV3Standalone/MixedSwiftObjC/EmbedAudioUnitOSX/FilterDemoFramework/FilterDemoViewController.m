/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller for the FilterDemo audio unit. Manages the interactions between a FilterView and the audio unit's parameters.
 */

#import <Cocoa/Cocoa.h>
#import <FilterDemoFramework/FilterDemo.h>
#import "FilterDemoViewController.h"
#import "FilterDemoViewController_Internal.h"
#import "FilterView.h"

@interface FilterDemoViewController () {
    __weak IBOutlet FilterView  *filterView;
    __weak IBOutlet NSTextField *frequencyLabel;
    __weak IBOutlet NSTextField *resonanceLabel;
    
    AUParameter *cutoffParameter;
    AUParameter *resonanceParameter;
    AUParameterObserverToken parameterObserverToken;
}

-(IBAction) setCutoff:(id)sender;
-(IBAction) setResonance:(id)sender;
@end

@implementation FilterDemoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    filterView.delegate = self;
    
    if (_audioUnit) {
        [self connectViewWithAU];
    }
    
    self.preferredContentSize = NSMakeSize(800, 500);
}

- (void)dealloc {
    filterView.delegate = nil;
    [self disconnectViewWithAU];
}

#pragma mark-
- (AUv3FilterDemo *)getAudioUnit {
    return _audioUnit;
}

- (void)setAudioUnit:(AUv3FilterDemo *)audioUnit {
    _audioUnit = audioUnit;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isViewLoaded]) {
            [self connectViewWithAU];
        }
    });
}

#pragma mark-
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    NSLog(@"FilterDemoViewControler allParameterValues key path changed: %s\n", keyPath.UTF8String);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        filterView.frequency = cutoffParameter.value;
        filterView.resonance = resonanceParameter.value;
        
        frequencyLabel.stringValue = [cutoffParameter stringFromValue: nil];
        resonanceLabel.stringValue = [resonanceParameter stringFromValue: nil];
        
        [self updateFilterViewFrequencyAndMagnitudes];
    });
}

- (void)connectViewWithAU {
    AUParameterTree *paramTree = _audioUnit.parameterTree;
    
    if (paramTree) {
        cutoffParameter = [paramTree valueForKey: @"cutoff"];
        resonanceParameter = [paramTree valueForKey: @"resonance"];
        
        // prevent retain cycle in parameter observer
        __weak FilterDemoViewController *weakSelf = self;
        __weak AUParameter *weakCutoffParameter = cutoffParameter;
        __weak AUParameter *weakResonanceParameter = resonanceParameter;
        parameterObserverToken = [paramTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
            __strong FilterDemoViewController *strongSelf = weakSelf;
            __strong AUParameter *strongCutoffParameter = weakCutoffParameter;
            __strong AUParameter *strongResonanceParameter = weakResonanceParameter;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (address == strongCutoffParameter.address){
                    strongSelf->filterView.frequency = value;
                    strongSelf->frequencyLabel.stringValue = [strongCutoffParameter stringFromValue: nil];
                } else if (address == strongResonanceParameter.address) {
                    strongSelf->filterView.resonance = value;
                    strongSelf->resonanceLabel.stringValue = [strongResonanceParameter stringFromValue: nil];
                }
                
                [strongSelf updateFilterViewFrequencyAndMagnitudes];
            });
        }];
        
        filterView.frequency = cutoffParameter.value;
        filterView.resonance = resonanceParameter.value;
        frequencyLabel.stringValue = [cutoffParameter stringFromValue: nil];
        resonanceLabel.stringValue = [resonanceParameter stringFromValue: nil];
        
        [_audioUnit addObserver:self forKeyPath:@"allParameterValues"
                        options:NSKeyValueObservingOptionNew
                        context:parameterObserverToken];
    }
    else
    {
        NSLog(@"paramTree is NULL!\n");
    }
}

- (void)disconnectViewWithAU {
    if (parameterObserverToken) {
        [_audioUnit.parameterTree removeParameterObserver:parameterObserverToken];
        [_audioUnit removeObserver:self forKeyPath:@"allParameterValues" context:parameterObserverToken];
        parameterObserverToken = 0;
    }
}

#pragma mark -
#pragma mark: <FilterViewDelegate>

- (void) updateFilterViewFrequencyAndMagnitudes {
    if (!_audioUnit) return;
    
    NSArray *frequencies = [filterView frequencyDataForDrawing];
    NSArray *magnitudes  = [_audioUnit magnitudesForFrequencies:frequencies];
    
    [filterView setMagnitudes: magnitudes];
}

- (void)filterViewDataDidChange:(FilterView *)sender {
    [self updateFilterViewFrequencyAndMagnitudes];
}

- (void)filterViewDidChange:(FilterView *)sender frequency:(double)frequency {
    cutoffParameter.value = frequency;
    
    [self updateFilterViewFrequencyAndMagnitudes];
}

- (void)filterViewDidChange:(FilterView *)sender resonance:(double)resonance {
    resonanceParameter.value = resonance;
    
    [self updateFilterViewFrequencyAndMagnitudes];
}

#pragma mark: Actions

- (IBAction) setCutoff:(id) sender {
    if (sender == frequencyLabel)
        cutoffParameter.value = frequencyLabel.floatValue;
    
    [self updateFilterViewFrequencyAndMagnitudes];
}

- (IBAction) setResonance:(id) sender {
    if (sender == resonanceLabel)
        resonanceParameter.value = resonanceLabel.floatValue;
    
    [self updateFilterViewFrequencyAndMagnitudes];
}

@end

