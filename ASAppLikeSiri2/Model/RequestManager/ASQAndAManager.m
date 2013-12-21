//
//  ASChatRequestManager.m
//  ASAppLikeSiri
//
//  Created by sakahara on 2013/12/17.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASQAndAManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation ASQAndAManager

static const NSString * API_KEY = @"xxxxxxx";

+ (instancetype)sharedManager
{
    static ASQAndAManager *_sharedManager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ASQAndAManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)fetchQARequest:(NSString *)question completionHandler:(void (^)(NSDictionary *result, NSError *error)) completionHandler
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    
    // パラメータの設定
    NSDictionary* param = @{@"q" : question};
    [manager GET:[NSString stringWithFormat:
                   @"https://api.apigw.smt.docomo.ne.jp/knowledgeQA/v1/ask/?APIKEY=%@", API_KEY]
        parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"parameters: %@", operation.request);
        NSLog(@"response: %@", responseObject);
        
        if (completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

@end
