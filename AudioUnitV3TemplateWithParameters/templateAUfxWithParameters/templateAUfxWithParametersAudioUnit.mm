//
//  templateAUfxWithParametersAudioUnit.m
//  templateAUfxWithParameters
//
//  Created by mhamilt7 on 11/07/2018.
//  Copyright © 2018 mhamilt7. All rights reserved.
//
//==============================================================================
#import "templateAUfxWithParametersAudioUnit.h"
#import <AVFoundation/AVFoundation.h>
#import "DSPKernel.hpp"
#import "BufferedAudioBus.hpp"
//==============================================================================
// Define parameter addresses.
const AUParameterAddress myParam1 = 0;
//==============================================================================
@interface templateAUfxWithParametersAudioUnit ()
@property (nonatomic, readwrite) AUParameterTree *parameterTree;
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray ;
@end
//==============================================================================
@implementation templateAUfxWithParametersAudioUnit
{
    // Add your C++ Classes Here:
    BufferedInputBus _inputBus;
    DSPKernel  _kernel;
}
@synthesize parameterTree = _parameterTree;
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
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0
                                                                                  channels:2];
    //==========================================================================
    // Create parameter objects Here
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"param1"
                                                                    name:@"Parameter 1"
                                                                 address:myParam1
                                                                     min:0
                                                                     max:100
                                                                    unit:kAudioUnitParameterUnit_Percent
                                                                unitName:nil
                                                                   flags:0
                                                            valueStrings:nil
                                                     dependentParameters:nil];
    //--------------------------------------------------------------------------
    param1.value = 0.5; // Initialize the parameter values.
    //--------------------------------------------------------------------------
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];  // Create the parameter tree.
    //--------------------------------------------------------------------------
    // Set .implementorStringFromValueCallback of a type
    // AUImplementorStringFromValueCallbackto to a pointer to a function
    // that represents the parameter value as a string
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr)
    {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        switch (param.address)
        {
            case myParam1:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    //--------------------------------------------------------------------------
     __block DSPKernel *localCaptureKernel = &_kernel; // Make local ptr of kernel to avoid capturing self.
    //--------------------------------------------------------------------------
    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value)
    {
         localCaptureKernel->setParameter(param.address, value);
    };
    //--------------------------------------------------------------------------
    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param)
    {
        return localCaptureKernel->getParameter(param.address);
    };
    //==========================================================================
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
        state->processWithEvents(timestamp,
                                 frameCount,
                                 realtimeEventListHead,
                                 inAudioBufferList,
                                 outAudioBufferList);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        return noErr;
    };
}
//==============================================================================
@end

