//
//  NSData+LBWAdditions.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/17.
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
