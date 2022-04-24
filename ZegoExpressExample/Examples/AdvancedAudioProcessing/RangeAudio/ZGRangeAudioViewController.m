//
//  ZGRangeAudioViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2021/8/10.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGRangeAudioViewController.h"
#import "KeyCenter.h"
#import "ZGRangeAudioUserPositionCell.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>


// User Position Info
@interface ZegoUserPositionInfo : NSObject
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *position;
@end

@implementation ZegoUserPositionInfo
@end



// Define other user position section in table view.
static int kRangeAudioUserPositionSection = 6;

@interface ZGRangeAudioViewController () <ZegoEventHandler, ZegoRangeAudioEventHandler, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ZegoRangeAudio *rangeAudio;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;

@property (weak, nonatomic) IBOutlet UILabel *audioModeLabel;

@property (weak, nonatomic) IBOutlet UILabel *teamIDLabel;

@property (weak, nonatomic) IBOutlet UITextField *teamIDTextField;

@property (weak, nonatomic) IBOutlet UILabel *receiveRangeLabel;

@property (weak, nonatomic) IBOutlet UITextField *receiveRangeTextField;

@property (weak, nonatomic) IBOutlet UILabel *enableMicrophoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *enableSpeakerLabel;

@property (weak, nonatomic) IBOutlet UILabel *soundEffects3DLabel;

@property (weak, nonatomic) IBOutlet UILabel *frontPositionLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightPositionLabel;

@property (weak, nonatomic) IBOutlet UILabel *upPositionLabel;

@property (weak, nonatomic) IBOutlet UILabel *axisFrontLabel;

@property (weak, nonatomic) IBOutlet UILabel *axisRightLabel;

@property (weak, nonatomic) IBOutlet UILabel *axisUpLabel;

@property (weak, nonatomic) IBOutlet UITextField *muteUserIDText;
// room user list
@property (nonatomic, strong) NSMutableArray<ZegoUserPositionInfo *> *userPositionList;

// Self positon. front, right, up
@property (nonatomic, assign) float *self_position;

// Rotation angle
@property (nonatomic, assign) float *rotate_angle;

// Rotation matrix in the forward direction
@property (nonatomic, assign) float *matrix_rotate_front;
// Rotation matrix in the right direction
@property (nonatomic, assign) float *matrix_rotate_right;
// Rotation matrix in the up direction
@property (nonatomic, assign) float *matrix_rotate_up;

@end

@implementation ZGRangeAudioViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataAndUI];
    [self createEngine];
    [self createRangeAudio];
}

- (void)setupDataAndUI {
    [self.tableView registerNib:[UINib nibWithNibName:@"ZGRangeAudioUserPositionCell" bundle:nil] forCellReuseIdentifier:@"ZGRangeAudioUserPositionCell"];
    
    self.userIDTextField.text = [KeyCenter userID];
    self.userIDTextField.enabled = false;
    
    _self_position = calloc(3, sizeof(float));
    _rotate_angle = calloc(3, sizeof(float));
    _matrix_rotate_front = calloc(3, sizeof(float));
    _matrix_rotate_right = calloc(3, sizeof(float));
    _matrix_rotate_up = calloc(3, sizeof(float));
    
    // Set default matrix
    eulerAnglesToRotationMatrix(_rotate_angle, _matrix_rotate_front, _matrix_rotate_right, _matrix_rotate_up);
}

- (void)createEngine {
    [self appendLog: [NSString stringWithFormat:@"🚀 Create ZegoExpressEngine"]];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)

    ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
    config.advancedConfig = @{@"max_channels": @"3", @"room_user_update_optimize": @"1"};
    [ZegoExpressEngine setEngineConfig:config];
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (void)createRangeAudio {
    self.rangeAudio = [[ZegoExpressEngine sharedEngine] createRangeAudio];
    if (self.rangeAudio) {
        [self appendLog:[NSString stringWithFormat:@"💽 Create ZegoRangeAudio"]];
    } else {
        [self appendLog:[NSString stringWithFormat:@"💽 ❌ Create ZegoRangeAudio failed"]];
        return;
    }

    [self.rangeAudio setEventHandler:self];
    [self.rangeAudio setAudioReceiveRange:[self.receiveRangeTextField.text floatValue]];
}

- (void)dealloc {
    [self appendLog:[NSString stringWithFormat:@"🏳️ Destroy ZegoExpressEngine"]];
    [ZegoExpressEngine destroyEngine:nil];
    
    free(_self_position);
    free(_rotate_angle);
    free(_matrix_rotate_front);
    free(_matrix_rotate_right);
    free(_matrix_rotate_up);
    
    _self_position = NULL;
    _rotate_angle = NULL;
    _matrix_rotate_front = NULL;
    _matrix_rotate_right = NULL;
    _matrix_rotate_up = NULL;
}

#pragma mark - Actions
- (IBAction)onRoomIDInput:(UITextField *)sender {
    self.roomIDTextField.text = sender.text;
}

- (IBAction)onUserIDInput:(UITextField *)sender {
//    self.userIDTextField.text = sender.text;
}

- (IBAction)onTeamIDInput:(UITextField *)sender {
    
    // Set team id
    [self.rangeAudio setTeamID:self.teamIDTextField.text];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Set team id: %@", self.teamIDTextField.text]];
}

- (IBAction)onReceiveRangeInput:(UITextField *)sender {
    
    float range = [self.receiveRangeTextField.text floatValue];
    
    // Set receive range
    [self.rangeAudio setAudioReceiveRange:range];
    
    // Print log
    [self appendLog:[NSString stringWithFormat:@"📤 Set receive range: %f", range]];
}

- (IBAction)onLoginRoomButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // LogoutRoom1
        [self appendLog:[NSString stringWithFormat:@"📤 Logout Room roomID: %@", self.roomIDTextField.text]];
        [self.userPositionList removeAllObjects];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRangeAudioUserPositionSection] withRowAnimation:UITableViewRowAnimationFade];
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomIDTextField.text];
    } else {
        // Login Room1
        [self appendLog:[NSString stringWithFormat:@"🚪 Login Room roomID: %@", self.roomIDTextField.text]];

        ZegoRoomConfig *roomConfig = [ZegoRoomConfig defaultConfig];
        roomConfig.isUserStatusNotify = YES;
        roomConfig.token = [KeyCenter token];
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomIDTextField.text user:[ZegoUser userWithUserID:self.userIDTextField.text] config:roomConfig];
        
        [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onChangeAudioMode:(UISegmentedControl *)sender {
    ZegoRangeAudioMode mode = (ZegoRangeAudioMode) sender.selectedSegmentIndex;
    
    // Set audio mode
    [self.rangeAudio setRangeAudioMode:mode];
    
    // Print log
    [self appendLog:[NSString stringWithFormat:@"📤 Set range audio mode: %td", mode]];
}

- (IBAction)onSwitchMicrophone:(UISwitch *)sender {
    // Enable microphone
    [self.rangeAudio enableMicrophone:sender.on];
    
    // Print log
    [self appendLog:[NSString stringWithFormat:@"📤 Enable microphone: %d", sender.on]];
}

- (IBAction)onSwitchSpeaker:(UISwitch *)sender {
    // Enable speaker
    [self.rangeAudio enableSpeaker:sender.on];
    
    // Print log
    [self appendLog:[NSString stringWithFormat:@"📤 Enable speaker: %d", sender.on]];
}

- (IBAction)onSwitch3DSoundEffects:(UISwitch *)sender {
    // Enable speaker
    [self.rangeAudio enableSpatializer:sender.on];
    
    // Print log
    [self appendLog:[NSString stringWithFormat:@"📤 Enable spatializer: %d", sender.on]];
}

- (IBAction)onSwitchMuteUser:(UISwitch *)sender {
    NSString *user_id = [self.muteUserIDText text];
    [self.rangeAudio muteUser:user_id mute:sender.on];
}


- (IBAction)onFrontPosition:(UISlider *)sender {
    _self_position[0] = sender.value;
    
    eulerAnglesToRotationMatrix(_rotate_angle, _matrix_rotate_front, _matrix_rotate_right, _matrix_rotate_up);
    
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    /// 发送房间广播信令
    /// ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
    /// Send room broadcast message
    /// ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
    [ZegoExpressEngine.sharedEngine sendBroadcastMessage:[NSString stringWithFormat:@"%f,%f,%f", _self_position[0], _self_position[1], _self_position[2]] roomID:self.roomIDTextField.text callback:^(int errorCode, unsigned long long messageID) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID]];
    }];
    
    self.frontPositionLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Update front position: %.0f", sender.value]];
}

- (IBAction)onRightPosition:(UISlider *)sender {
    _self_position[1] = sender.value;
        
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    /// 发送房间广播信令
    /// ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
    /// Send room broadcast message
    /// ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
    [ZegoExpressEngine.sharedEngine sendBroadcastMessage:[NSString stringWithFormat:@"%f,%f,%f", _self_position[0], _self_position[1], _self_position[2]] roomID:self.roomIDTextField.text callback:^(int errorCode, unsigned long long messageID) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID]];
    }];
    
    self.rightPositionLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Update right position: %.0f", sender.value]];
}

- (IBAction)onUpPosition:(UISlider *)sender {
    _self_position[2] = sender.value;
        
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    /// 发送房间广播信令
    /// ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
    /// Send room broadcast message
    /// ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
    [ZegoExpressEngine.sharedEngine sendBroadcastMessage:[NSString stringWithFormat:@"%f,%f,%f", _self_position[0], _self_position[1], _self_position[2]] roomID:self.roomIDTextField.text callback:^(int errorCode, unsigned long long messageID) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID]];
    }];
    
    self.upPositionLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Update up position: %.0f", sender.value]];
}

- (IBAction)onFrontAxis:(UISlider *)sender {
    
    _rotate_angle[0] = sender.value * M_PI / 180;
    
    eulerAnglesToRotationMatrix(_rotate_angle, _matrix_rotate_front, _matrix_rotate_right, _matrix_rotate_up);
    
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    self.axisFrontLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Rotate around the front axis: %.0f", sender.value]];
}

- (IBAction)onRightAxis:(UISlider *)sender {
    _rotate_angle[1] = sender.value * M_PI / 180;
    
    eulerAnglesToRotationMatrix(_rotate_angle, _matrix_rotate_front, _matrix_rotate_right, _matrix_rotate_up);
    
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    self.axisRightLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Rotate around the right axis: %.0f", sender.value]];
}

- (IBAction)onUpAxis:(UISlider *)sender {
    _rotate_angle[2] = sender.value * M_PI / 180;
    
    eulerAnglesToRotationMatrix(_rotate_angle, _matrix_rotate_front, _matrix_rotate_right, _matrix_rotate_up);
    
    // Update self audio position
    [self.rangeAudio updateSelfPosition:_self_position axisForward:_matrix_rotate_front axisRight:_matrix_rotate_right axisUp:_matrix_rotate_up];
    
    self.axisUpLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Rotate around the up axis: %.0f", sender.value]];
}

#pragma mark - Range Audio Event Handler
- (void)rangeAudio:(ZegoRangeAudio *)rangeAudio microphoneStateUpdate:(ZegoRangeAudioMicrophoneState)state errorCode:(int)errorCode {
    [self appendLog:[NSString stringWithFormat:@"🚩 💽 microphone state update. state: %td, errorCode: %d", state, errorCode]];
}

#pragma mark - On room
- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    
    [self appendLog:[NSString stringWithFormat:@"🚩 🕺 Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID]];
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoUser *user in userList) {
            ZegoUserPositionInfo *info = [ZegoUserPositionInfo new];
            info.userID = user.userID;
            info.position = @"";
            [self.userPositionList addObject:info];
        }
        NSString *message = [NSString stringWithFormat:@"%f,%f,%f", _self_position[0], _self_position[1], _self_position[2]];
        /// 发送房间广播信令
        /// ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
        /// Send room broadcast message
        /// ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZegoExpressEngine.sharedEngine sendBroadcastMessage:message roomID:self.roomIDTextField.text callback:^(int errorCode, unsigned long long messageID) {
                [self appendLog:[NSString stringWithFormat:@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID]];
            }];
        });
    } else {
        NSArray *userPositionArray = self.userPositionList.copy;
        for (ZegoUser *user in userList) {
            for (ZegoUserPositionInfo *info in userPositionArray) {
                if ([user.userID isEqualToString:info.userID]) {
                    [self.userPositionList removeObject:info];
                }
            }
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRangeAudioUserPositionSection] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onIMRecvBroadcastMessage:(NSArray<ZegoBroadcastMessageInfo *> *)messageList roomID:(NSString *)roomID {
    
    for (ZegoBroadcastMessageInfo *messageInfo in messageList) {
        
        NSArray *positionList = [messageInfo.message componentsSeparatedByString:@","];
        float position[3] = {[positionList[0] floatValue], [positionList[1] floatValue], [positionList[2] floatValue]};
        for (ZegoUserPositionInfo *positionInfo in self.userPositionList) {
            if ([messageInfo.fromUser.userID isEqualToString:positionInfo.userID]) {
                positionInfo.position = [NSString stringWithFormat:@"%.0f,%.0f,%.0f", position[0], position[1], position[2]];
            }
        }
        // Update other user audio position
        [self.rangeAudio updateAudioSource:messageInfo.fromUser.userID position:position];
    }
    
    // Reload user position section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRangeAudioUserPositionSection] withRowAnimation:UITableViewRowAnimationFade];
    
    [self appendLog:[NSString stringWithFormat:@"🚩 💬 IM Recv Broadcast Message Callback: roomID: %@", roomID]];
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBroadcastMessageInfo *info = messageList[idx];
        [self appendLog:[NSString stringWithFormat:@"🚩 💬 %@ [FromUserID: %@]", info.message, info.fromUser.userID]];
    }
}

#pragma mark - Table view data source & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kRangeAudioUserPositionSection) {
        return self.userPositionList.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRangeAudioUserPositionSection) {
        ZGRangeAudioUserPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZGRangeAudioUserPositionCell"];
        ZegoUserPositionInfo *info = self.userPositionList[indexPath.row];
        [cell setMessage:info.position userID:info.userID];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRangeAudioUserPositionSection) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kRangeAudioUserPositionSection]];
    }
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRangeAudioUserPositionSection) {
        return 50;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Helper
void eulerAnglesToRotationMatrix(float theta[3],
                                 float matrix_front[3],
                                 float matrix_right[3],
                                 float matrix_up[3])
{
    float matrix_rotate_front[3][3] = {
        {1,0,0},
        {0,cos(theta[0]),-sin(theta[0])},
        {0,sin(theta[0]),cos(theta[0])}
    };

    float matrix_rotate_right[3][3] = {
        {cos(theta[1]),0,sin(theta[1])},
        {0,1,0},
        {-sin(theta[1]),0,cos(theta[1])}
    };

    float matrix_rotate_up[3][3] = {
        {cos(theta[2]),-sin(theta[2]),0},
        {sin(theta[2]),cos(theta[2]),0},
        {0,0,1}
    };

    float matrix_rotate[3][3];
    float matrix_rotate_temp[3][3];
    
    matrixMultiply(matrix_rotate_front, matrix_rotate_right, matrix_rotate_temp);
    matrixMultiply(matrix_rotate_temp, matrix_rotate_up, matrix_rotate);

    matrix_front[0] = matrix_rotate[0][0];
    matrix_front[1] = matrix_rotate[1][0];
    matrix_front[2] = matrix_rotate[2][0];
    
    matrix_right[0] = matrix_rotate[0][1];
    matrix_right[1] = matrix_rotate[1][1];
    matrix_right[2] = matrix_rotate[2][1];
    
    matrix_up[0] = matrix_rotate[0][2];
    matrix_up[1] = matrix_rotate[1][2];
    matrix_up[2] = matrix_rotate[2][2];
}

void matrixMultiply(float a[3][3], float b[3][3], float dst[3][3]) {
    for(int i=0; i<3; i++) {
        for(int j=0;j<3;j++) {
            dst[i][j] = 0;
            for(int k=0;k<3;k++) {
                dst[i][j] += a[i][k]*b[k][j];
            }
        }
    }
}

- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }

    ZGLogInfo(@"%@", tipText);

    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];

    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Getter
- (NSMutableArray<ZegoUserPositionInfo *> *)userPositionList {
    if (!_userPositionList) {
        _userPositionList = [NSMutableArray new];
    }
    return _userPositionList;
}

@end



///  Rewrite system equal function
@interface ZegoUser (Deduplication)

@end

@implementation ZegoUser (Deduplication)

- (BOOL)isEqual:(ZegoUser *)object {
    if (self.userID == object.userID) {
        return YES;
    }
    return NO;
}

@end
