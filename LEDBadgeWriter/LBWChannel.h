//
//  LBWChannel.h
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
