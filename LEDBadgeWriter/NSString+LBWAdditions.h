//
//  NSString+LBWAdditions.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/12.
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
