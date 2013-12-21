//
//  ASViewController.m
//  ASAppLikeSiri2
//
//  Created by sakahara on 2013/12/21.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASQAndAViewController.h"
#import "ASQAndAManager.h"
#import "AVFoundation/AVFoundation.h"

static const NSString * kYou = @"あなた";
static const NSString * kOpponent = @"ひつじくん";

@interface ASQAndAViewController () <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@end

@implementation ASQAndAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont: [UIFont systemFontOfSize:16.0]];
    // キーボードを表示する
    [self.messageInputView.textView becomeFirstResponder];
    
    self.title = @"Messages";
    
    self.messageInputView.textView.placeHolder = @"Message";
    
    self.messages = [[NSMutableArray alloc] init];
    self.timestamps = [[NSMutableArray alloc] init];
    self.subtitles = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    [self.messages addObject:text];
    [self.timestamps addObject:[NSDate date]];
    [self.subtitles addObject:kYou];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    [JSMessageSoundEffect playMessageSentSound];
    
    __weak typeof(self) weakSelf = self;
    
    [[ASQAndAManager sharedManager]
     fetchQARequest:text completionHandler:^(NSDictionary *result, NSError *error) {
         if (!error) {
             
             NSDictionary *messageInfo = result[@"message"];
             
             NSString *message = messageInfo[@"textForDisplay"];
             [weakSelf.messages addObject:message];
             
             [weakSelf.timestamps addObject:[NSDate date]];
             [weakSelf.subtitles addObject:kOpponent];
             
             [weakSelf finishSend];
             [weakSelf scrollToBottomAnimated:YES];
             
             // AVSpeechSynthesizerの初期化
             AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
             // 読み上げるテキストの設定
             AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
             // 読み上げる言語の設定
             utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];
             // 声の高さを設定（0.5〜2.0）
             utterance.pitchMultiplier = 1.0;
             // 読み上げ開始
             [synthesizer speakUtterance:utterance];
         }
     }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.subtitles[indexPath.row] isEqual:kYou]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.subtitles[indexPath.row] isEqual:kYou]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleGreenColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleLightGrayColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.subtitles objectAtIndex:indexPath.row];
}

@end
