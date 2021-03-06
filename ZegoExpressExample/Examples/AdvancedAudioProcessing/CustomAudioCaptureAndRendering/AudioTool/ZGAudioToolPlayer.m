

#import "ZGAudioToolPlayer.h"
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioToolCommon.h"
#import <assert.h>

@implementation ZGAudioToolPlayer
{
    AudioUnit audioUnit;
    AudioBufferList *buffList;
    int _sampleRate;
    int _bufferSize;
}

- (instancetype)initWithSampleRate:(Float64)sampleRate bufferSize:(int)bufferSize {
    if (self = [super init]) {
        _sampleRate = sampleRate;
        _bufferSize = bufferSize;
    }
    return self;
}

- (void)play {
    [self initPlayer];
    AudioOutputUnitStart(audioUnit);
}


- (double)getCurrentTime {
    Float64 timeInterval = 0;
    
    return timeInterval;
}



- (void)initPlayer {
    NSError *error = nil;
    OSStatus status = noErr;
    
    // set audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    // buffer
    buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    buffList->mNumberBuffers = 1;
    buffList->mBuffers[0].mNumberChannels = 1;
    buffList->mBuffers[0].mDataByteSize = _bufferSize;
    buffList->mBuffers[0].mData = malloc(_bufferSize);
    
    //audio property
    UInt32 flag = 1;
    if (flag) {
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Output,
                                      OUTPUT_BUS,
                                      &flag,
                                      sizeof(flag));
    }
    if (status) {
        NSLog(@"AudioUnitSetProperty error with status:%d", status);
    }
    
    // format
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate       = _sampleRate; // ?????????
    outputFormat.mFormatID         = kAudioFormatLinearPCM; // PCM??????
    outputFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger; // ??????
    outputFormat.mFramesPerPacket  = 1; // ????????????1???packet
    outputFormat.mChannelsPerFrame = 1; // ?????????
    outputFormat.mBytesPerFrame    = 2; // ????????????2???byte ??????*??????*Packet???
    outputFormat.mBytesPerPacket   = 2; // ??????Packet??????2???byte
    outputFormat.mBitsPerChannel   = 16; // ??????
    [self printAudioStreamBasicDescription:outputFormat];

    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  OUTPUT_BUS,
                                  &outputFormat,
                                  sizeof(outputFormat));
    if (status) {
        NSLog(@"AudioUnitSetProperty eror with status:%d", status);
    }
    
    
    // callback
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = PlayCallback;
    playCallback.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         OUTPUT_BUS,
                         &playCallback,
                         sizeof(playCallback));
    
    
    OSStatus result = AudioUnitInitialize(audioUnit);
    NSLog(@"result %d", result);
}


static OSStatus PlayCallback(void *inRefCon,
                             AudioUnitRenderActionFlags *ioActionFlags,
                             const AudioTimeStamp *inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList *ioData) {
    ZGAudioToolPlayer *player = (__bridge ZGAudioToolPlayer *)inRefCon;
    typeof(player) __weak weakPlayer = player;
//    ioData->mBuffers[0].mDataByteSize = (UInt32)[player->inputSteam read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];
//    NSLog(@"out size: %d", ioData->mBuffers[0].mDataByteSize);
    if (player.bl_input)
    {
        player.bl_input(weakPlayer, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    }
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [player stop];
        });
    }
    return noErr;
}


- (void)stop {
    AudioOutputUnitStop(audioUnit);
    if (buffList != NULL) {
        if (buffList->mBuffers[0].mData) {
            free(buffList->mBuffers[0].mData);
            buffList->mBuffers[0].mData = NULL;
        }
        free(buffList);
        buffList = NULL;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayToEnd:)]) {
        __strong typeof (ZGAudioToolPlayer) *player = self;
        [self.delegate onPlayToEnd:player];
    }
//    AudioUnitUninitialize(audioUnit);
//    AudioComponentInstanceDispose(audioUnit);
}

- (void)dealloc {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    
    if (buffList != NULL) {
        free(buffList);
        buffList = NULL;
    }
}


- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}
@end
