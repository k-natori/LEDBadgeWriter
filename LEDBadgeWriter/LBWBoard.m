//
//  LBWBoard.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/12/06.
//  k_natori@mac.com

//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LBWBoard.h"
#import "LBWChannel.h"
#import "NSString+LBWAdditions.h"
#import "NSData+LBWAdditions.h"

@implementation LBWBoard

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.channels forKey:@"channels"];
    [aCoder encodeObject:self.font.fontName forKey:@"fontName"];
    [aCoder encodeFloat:self.font.pointSize forKey:@"fontSize"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.channels = [decoder decodeObjectForKey:@"channels"];
        NSString *fontName = [decoder decodeObjectForKey:@"fontName"];
        CGFloat fontSize = [decoder decodeFloatForKey:@"fontSize"];
        self.font = [NSFont fontWithName:fontName size:fontSize];
    }
    return self;
}

#pragma mark - Build Packets
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
