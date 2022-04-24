//
//  ZGCustomVideoRenderLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/1.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomVideoRenderLoginViewController.h"

#import "ZGCustomVideoRenderViewController.h"
NSString* const ZGCustomVideoRenderLoginVCKey_roomID = @"kRoomID";
NSString* const ZGCustomVideoRenderLoginVCKey_streamID = @"kStreamID";

@interface ZGCustomVideoRenderLoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSArray<NSString *> *renderBufferTypeList;
@property (nonatomic, copy) NSArray<NSString *> *renderFormatSeriesList;

@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderBufferTypeMap;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderFormatSeriesMap;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *renderTypeFormatPicker;
@property (weak, nonatomic) IBOutlet UISwitch *engineRenderSwitch;

@end

@implementation ZGCustomVideoRenderLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Render";
    
    self.roomIDTextField.text = @"0013";
    self.streamIDTextField.text = @"0013";
    
    self.renderBufferTypeList = @[@"CVPixelBuffer"];
    self.renderBufferTypeMap = @{@"Unknown": @(ZegoVideoBufferTypeUnknown), @"RawData": @(ZegoVideoBufferTypeRawData), @"CVPixelBuffer": @(ZegoVideoBufferTypeCVPixelBuffer), @"EncodedData": @(ZegoVideoBufferTypeEncodedData)};
    
    self.renderFormatSeriesList = @[@"RGB"];
    self.renderFormatSeriesMap = @{@"RGB": @(ZegoVideoFrameFormatSeriesRGB), @"YUV": @(ZegoVideoFrameFormatSeriesYUV)};
    
    [self setupUI];
}

- (void)setupUI {
    
    [self.renderTypeFormatPicker setDelegate:self];
    [self.renderTypeFormatPicker setDataSource:self];
    
    [self.renderTypeFormatPicker selectRow:2 inComponent:0 animated:YES]; // Select CVPixelBuffer
    [self.renderTypeFormatPicker selectRow:0 inComponent:1 animated:YES]; // Select RGB
}

- (BOOL)prepareForJump {
    if (!self.roomIDTextField.text || [self.roomIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in roomID.");
        return NO;
    }
    
    if (!self.streamIDTextField.text || [self.streamIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in streamID.");
        return NO;
    }

    return YES;
}

- (IBAction)publishStream:(UIButton *)sender {
    if (![self prepareForJump]) return;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
    ZGCustomVideoRenderViewController *viewController = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoRenderViewController class])];
    
    viewController.bufferType = (ZegoVideoBufferType)self.renderBufferTypeMap[self.renderBufferTypeList[[self.renderTypeFormatPicker selectedRowInComponent:0]]].intValue;
    
    viewController.frameFormatSeries = (ZegoVideoFrameFormatSeries)self.renderFormatSeriesMap[self.renderFormatSeriesList[[self.renderTypeFormatPicker selectedRowInComponent:1]]].intValue;
    
    viewController.roomID = self.roomIDTextField.text;
    viewController.streamID = self.streamIDTextField.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.renderBufferTypeList.count;
    } else {
        return self.renderFormatSeriesList.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.renderBufferTypeList[row];
    } else {
        return self.renderFormatSeriesList[row];
    }
}

@end
