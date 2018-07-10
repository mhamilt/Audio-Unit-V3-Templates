//
//  templateAUfxAudioUnit.m
//  templateAUfx
//
//  Created by mhamilt7 on 10/07/2018.
//  Copyright © 2018 mhamilt7. All rights reserved.
//
//==============================================================================
#import "templateAUfxAudioUnit.h"
#import <AVFoundation/AVFoundation.h>
#import "DSPKernel.hpp"
#import "BufferedAudioBus.hpp"
//==============================================================================
@interface templateAUfxAudioUnit ()
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;
@end
//==============================================================================
@implementation templateAUfxAudioUnit
{
    // Add your C++ Classes Here:
    BufferedInputBus _inputBus;
    DSPKernel  _kernel;
}
//==============================================================================

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError
{
    //--------------------------------------------------------------------------
    self = [super initWithComponentDescription:componentDescription
                                       options:options
                                         error:outError];
    if (self == nil) { return nil; }
    //--------------------------------------------------------------------------
    // @invalidname: Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    //--------------------------------------------------------------------------
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);
    //==========================================================================
    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    //--------------------------------------------------------------------------
    // Create the input and output bus arrays
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses: @[_inputBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    //--------------------------------------------------------------------------
    self.maximumFramesToRender = 512;
    //--------------------------------------------------------------------------
    return self;
}

-(void)dealloc
{
    
}

//==============================================================================
#pragma mark - AUAudioUnit Overrides

- (AUAudioUnitBusArray *)inputBusses
{
    return _inputBusArray;
}

- (AUAudioUnitBusArray *)outputBusses
{
    return _outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError
{
    //--------------------------------------------------------------------------
    if (![super allocateRenderResourcesAndReturnError:outError])
    {
        return NO;
    }
    //--------------------------------------------------------------------------
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount)
    {
        if (outError)
        {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
        }
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;
        
        return NO;
    }
    //--------------------------------------------------------------------------
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    //--------------------------------------------------------------------------
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    //--------------------------------------------------------------------------
    return YES;
}
//==============================================================================
// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources
{
    //--------------------------------------------------------------------------
    _inputBus.deallocateRenderResources();
    //--------------------------------------------------------------------------
    [super deallocateRenderResources];
}

//==============================================================================
#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock
{
    //--------------------------------------------------------------------------
    // C++ pointers: Referred to as 'captures', make them mutable with __block
    // Capture in locals to avoid ObjC member lookups.
    __block DSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;
    //--------------------------------------------------------------------------
    return ^AUAudioUnitStatus (AudioUnitRenderActionFlags *actionFlags,
                               const AudioTimeStamp *timestamp,
                               AVAudioFrameCount frameCount,
                               NSInteger outputBusNumber,
                               AudioBufferList *outputData,
                               const AURenderEvent *realtimeEventListHead,
                               AURenderPullInputBlock pullInputBlock)
    {
        //----------------------------------------------------------------------
        AudioUnitRenderActionFlags pullFlags = 0;
        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);
        if (err != 0) { return err; }
        //----------------------------------------------------------------------
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        AudioBufferList *outAudioBufferList = outputData;
        if (outputData->mBuffers[0].mData == nullptr)
        {
            for (UInt32 i = 0; i < outputData->mNumberBuffers; ++i)
            {
                outputData->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // DSP Goes in process method of DSPKernel
        state->processWithEvents(frameCount,
                                 inAudioBufferList,
                                 outAudioBufferList);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        return noErr;
    };
}
//==============================================================================
@end


