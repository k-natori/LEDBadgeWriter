//
//  NSString+LBWAdditions.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/12.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSString (NSString_LBWAdditions)
// For Preview
-(NSImage *)imageOfStringUsingFont:(NSFont *)font textColor:(NSColor *)textColor backgroundColor:(NSColor *) backgroundColor ;
-(NSImage *)imageOfCharacterUsingFont:(NSFont *)font textColor:(NSColor *)textColor backgroundColor:(NSColor *) backgroundColor width:(CGFloat)width;

// For bitmap data 
-(NSData *)LBWDataOfCharacterUsingFont:(NSFont *)font ;
-(NSArray *)LBWDataArrayOfStringUsingFont:(NSFont *)font ;
@end
