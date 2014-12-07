//
//  LBWBoard.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/12/06.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import "LBWBoard.h"
#import "LBWChannel.h"
#import "NSString+LBWAdditions.h"
#import "NSData+LBWAdditions.h"

@implementation LBWBoard
-(NSArray *)packets {
    if (self.channels.count > 8) {
        self.channels = [self.channels subarrayWithRange:NSMakeRange(0, 8)];
    }
    if (!self.font) {
        self.font = [NSFont systemFontOfSize:12.0f];
    }
    
    NSMutableArray *allPackets = [NSMutableArray array];
    NSUInteger channelIndex = 0;
    unsigned char enabledChannelFlag = 0b00000000;
    unsigned char currentChannelFlag = 0b00000001;
    
    // Extended Char Set;
    NSMutableOrderedSet *tempExtendedCharactersSet = [NSMutableOrderedSet orderedSet];
    
    for (LBWChannel *channel in self.channels) {
        if (channel.enabled) {
            NSFont *tempFont = channel.font;
            if (!tempFont) {
                tempFont = self.font;
            }
            NSArray *dataArray = [channel dataArrayForExtendedCharactersUsingFont:tempFont];
            [tempExtendedCharactersSet addObjectsFromArray:dataArray];
        }
    }
    if (tempExtendedCharactersSet.count > 256) {
        [tempExtendedCharactersSet removeObjectsInRange:NSMakeRange(256, tempExtendedCharactersSet.count- 256)];
    }
    NSOrderedSet *extendedCharactersSet = [tempExtendedCharactersSet copy];
    
    // Text Data Packets for channels
    for (LBWChannel *channel in self.channels) {
        channel.channel = channelIndex;
        
        if (channel.enabled) {
            NSFont *tempFont = channel.font;
            if (!tempFont) {
                tempFont = self.font;
            }

            NSArray *tempPackets = [channel packetsUsingExtendedCharactersSet:extendedCharactersSet usingFont:tempFont];
            if (tempPackets) {
                [allPackets addObjectsFromArray:tempPackets];
                enabledChannelFlag = enabledChannelFlag | currentChannelFlag;
            }
        }
        
        channelIndex++;
        currentChannelFlag = currentChannelFlag << 1;
        
    }
    
    // Font Data Packets
    NSMutableData *allFontData = [NSMutableData data];
    for (NSData *oneFontData in extendedCharactersSet) {
        [allFontData appendData:oneFontData];
    }
    NSArray *fontDataPackets = [[allFontData copy] packetsFromAddress:0x0e00];
    [allPackets addObjectsFromArray:fontDataPackets];
    
    if (allPackets.count == 0) return nil;
    
    // terminate packet
    unsigned char footer[4];
    footer[0] = 2;
    footer[1] = '3';
    footer[2] = enabledChannelFlag;
    footer[3] = ((NSUInteger)(footer[1]) + (NSUInteger)footer[2]) % 256;;
    NSData *footerData = [NSData dataWithBytes:footer length:4];
    [allPackets addObject:footerData];

    return [allPackets copy];
}

@end
