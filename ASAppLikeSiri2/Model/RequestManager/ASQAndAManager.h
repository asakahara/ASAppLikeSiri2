//
//  ASChatRequestManager.h
//  ASAppLikeSiri
//
//  Created by sakahara on 2013/12/17.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASQAndAManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchQARequest:(NSString *)question completionHandler:(void (^)(NSDictionary *result, NSError *error)) completionHandler;

@end
