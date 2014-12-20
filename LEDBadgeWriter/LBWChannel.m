//
//  LBWChannel.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/01.
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

#import "LBWChannel.h"
#import "NSString+LBWAdditions.h"

NSCharacterSet *__asciiCharSet = nil;

@interface LBWChannel (LBWChannelInternal)
-(NSData *)stringDataUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font;
// Make string using all font data

-(NSData *)messageDataUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font;
// Make message body including header and text length
@end

@implementation LBWChannel

+(void)initialize {
    if (!__asciiCharSet) {
        __asciiCharSet = [NSCharacterSet characterSetWithRange:NSMakeRange(32, (126-32))];
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
    [aCoder encodeInteger:self.speed forKey:@"speed"];
    [aCoder encodeInteger:self.pattern forKey:@"pattern"];
    [aCoder encodeBool:self.enabled forKey:@"enabled"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.string = [decoder decodeObjectForKey:@"string"];
        self.speed = [decoder decodeIntegerForKey:@"speed"];
        self.pattern = [decoder decodeIntegerForKey:@"pattern"];
        self.enabled = [decoder decodeBoolForKey:@"enabled"];
    }
    return self;
}

+(instancetype)channelWithString:(NSString *)newString {
    LBWChannel *newChannel = [[self alloc] init];
    newChannel.string = newString;
    newChannel.speed = 4;
    newChannel.pattern = 1;
    newChannel.channel = 0;
    newChannel.enabled = YES;
    return newChannel;
}

-(NSData *)messageDataUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font {
    if (self.channel > 7) return nil;
    
    NSMutableData *result = [NSMutableData data];
    
    // Header
    char header[3];
    char speed[5] = "12345";
    char name[6] = "123456";
    char pattern[5] = "ABCDE";
    header[0] = speed[self.speed];
    header[1] = name[self.channel];
    header[2] = pattern[self.pattern];
    [result appendBytes:header length:3];
    
    // Text Data
    NSData *stringData = [self stringDataUsingExtendedCharactersSet:orderedSet usingFont:font];
    if (stringData.length > 250) return nil;
    
    // Data Length
    unsigned char stringDataLength = stringData.length;
    [result appendBytes:&stringDataLength length:1];
    [result appendData:stringData];
    
    return [result copy];
}

-(NSArray *)packetsUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font {
    NSData *messageData = [self messageDataUsingExtendedCharactersSet:orderedSet usingFont:font];
    if (!messageData) return nil;
    if (self.channel > 7) return nil;
    
    NSUInteger packetCount = ((messageData.length +1) / 64) +1;
    if (packetCount > 4) return nil;
    
    NSMutableArray *resultArray = [NSMutableArray array];
    char command = '1';
    unsigned char address[2];
    address[0] = 0x06 + self.channel;
    address[1] = 0x00;
    for (NSUInteger i=0; i<packetCount; i++) {
        
        // packet header
        unsigned char header[4];
        header[0] = 0x02;
        header[1] = command;
        header[2] = address[0];
        header[3] = address[1];
        
        // packet payload
        NSRange subDataRange = NSMakeRange(i*64, 64);
        if ((subDataRange.location + subDataRange.length) > messageData.length) {
            subDataRange.length = messageData.length - subDataRange.location;
        }
        NSData *subData = [messageData subdataWithRange:subDataRange];
        
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
        address[1] += 64;
    }
    
    return [resultArray copy];
}
-(NSArray *)dataArrayForExtendedCharactersUsingFont:(NSFont *)font {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:self.string];
    scanner.charactersToBeSkipped = [NSCharacterSet illegalCharacterSet];
    while (![scanner isAtEnd]) {
        NSString *asciiString = nil;
        [scanner scanCharactersFromSet:__asciiCharSet intoString:&asciiString];
        if (![scanner isAtEnd]) {
            NSString *nonAsciiString = nil;
            [scanner scanUpToCharactersFromSet:__asciiCharSet intoString:&nonAsciiString];
            if (nonAsciiString) {
                NSArray *dataArray = [nonAsciiString LBWDataArrayOfStringUsingFont:font];
                [resultArray addObjectsFromArray:dataArray];
            }
        }
    }
    return [resultArray copy];
}
-(NSData *)stringDataUsingExtendedCharactersSet:(NSOrderedSet *)orderedSet usingFont:(NSFont *)font {
    NSMutableData *resultData = [NSMutableData data];
    
    NSScanner *scanner = [NSScanner scannerWithString:self.string];
    scanner.charactersToBeSkipped = [NSCharacterSet illegalCharacterSet];
    while (![scanner isAtEnd]) {
        NSString *asciiString = nil;
        [scanner scanCharactersFromSet:__asciiCharSet intoString:&asciiString];
        if (asciiString) {
            NSData *asciiData = [asciiString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            [resultData appendData:asciiData];
        }
        
        if (![scanner isAtEnd]) {
            NSString *nonAsciiString = nil;
            [scanner scanUpToCharactersFromSet:__asciiCharSet intoString:&nonAsciiString];
            if (nonAsciiString) {
                NSArray *dataArray = [nonAsciiString LBWDataArrayOfStringUsingFont:font];
                for (NSData *charData in dataArray) {
                    NSUInteger index = [orderedSet indexOfObject:charData];
                    if (index != NSNotFound && index < UCHAR_MAX) {
                        unsigned char exChar[2];
                        exChar[0] = 0x80;
                        exChar[1] = (unsigned char)index;
                        [resultData appendBytes:exChar length:2];
                    }
                }
            }
        }
    }
    return [resultData copy];
}


@end
