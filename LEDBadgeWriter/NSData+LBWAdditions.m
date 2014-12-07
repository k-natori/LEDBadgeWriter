//
//  NSData+LBWAdditions.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/17.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import "NSData+LBWAdditions.h"

@implementation NSData (NSData_LBWAdditions)
-(NSArray *)packetsFromAddress:(UInt16)address {
    
    NSUInteger packetCount = ((self.length +1) / 64) +1;
    
    NSMutableArray *resultArray = [NSMutableArray array];
    char command = '1';
    for (NSUInteger i=0; i<packetCount; i++) {
        
        // packet header
        unsigned char header[4];
        header[0] = 0x02;
        header[1] = command;
        header[2] = (unsigned char)((address >> 8) & 0xff);
        header[3] = (unsigned char)(address & 0xff);
        
        // packet payload
        NSRange subDataRange = NSMakeRange(i*64, 64);
        if ((subDataRange.location + subDataRange.length) > self.length) {
            subDataRange.length = self.length - subDataRange.location;
        }
        NSData *subData = [self subdataWithRange:subDataRange];
        
        NSMutableData *packetData = [NSMutableData data];
        [packetData appendBytes:header length:4];
        [packetData appendData:subData];
        packetData.length = 64+4;
        
        // checksum
        
        unsigned char checksum = 0;
        for (NSUInteger j=1; j<packetData.length; j++) {
            unsigned char byte;
            [packetData getBytes:&byte range:NSMakeRange(j, 1)];
            checksum = ((NSUInteger)checksum + (NSUInteger)byte) % 256;
        }
        [packetData appendBytes:&checksum length:1];
        [resultArray addObject:[packetData copy]];
        
        // next
        address += 64;
        //command = '2';
    }
    
    return [resultArray copy];

}
@end
