//
//  LBWChannel.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/01.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LBWChannel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *string;
@property (nonatomic) NSInteger speed;
@property (nonatomic) NSInteger pattern;
@property (nonatomic) NSUInteger channel;
@property (nonatomic) BOOL enabled;

@property (nonatomic, strong) NSFont *font;

+(instancetype)channelWithString:(NSString *)newString ;

-(NSArray *)dataArrayForExtendedCharactersUsingFont:(NSFont *)font;
    // First, extract non-ASCII characters and make temporary font bitmap data

-(NSArray *)packetsUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font;
    // Second, Make packets using overall non-ASCII font data;

@end
