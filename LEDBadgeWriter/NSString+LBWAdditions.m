//
//  NSString+LBWAdditions.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/12.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import "NSString+LBWAdditions.h"
#import "NSImage+LBWAdditions.h"


NSCharacterSet *__asciiCharSet2 = nil;

@implementation NSString (NSString_LBWAdditions)

-(NSImage *)imageOfStringUsingFont:(NSFont *)font textColor:(NSColor *)textColor backgroundColor:(NSColor *) backgroundColor {
    if (!font) font = [NSFont systemFontOfSize:12.0f];
    if (!textColor) textColor = [NSColor blackColor];
    if (!backgroundColor) backgroundColor = [NSColor whiteColor];
    if (!__asciiCharSet2) {
        __asciiCharSet2 = [NSCharacterSet characterSetWithRange:NSMakeRange(32, (126-32))];
    }
    NSFont *systemFont = [NSFont systemFontOfSize:12.0f];
    
    NSMutableArray *images = [NSMutableArray array];
    CGFloat totalWidth = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    scanner.charactersToBeSkipped = [NSCharacterSet illegalCharacterSet];
    while (![scanner isAtEnd]) {
        NSString *asciiString = nil;
        [scanner scanCharactersFromSet:__asciiCharSet2 intoString:&asciiString];
        if (asciiString) {
            for (NSUInteger i=0; i<asciiString.length; i++) {
                NSString *charString = [asciiString substringWithRange:NSMakeRange(i, 1)];
                NSImage *charImage = [charString imageOfCharacterUsingFont:systemFont textColor:textColor backgroundColor:backgroundColor width:8.0f];
                if (charImage) {
                    [images addObject:charImage];
                    totalWidth += 8.0f;
                }
            }
        }
        
        if (![scanner isAtEnd]) {
            NSString *nonAsciiString = nil;
            [scanner scanUpToCharactersFromSet:__asciiCharSet2 intoString:&nonAsciiString];
            if (nonAsciiString) {
                for (NSUInteger i=0; i<nonAsciiString.length; i++) {
                    NSString *charString = [nonAsciiString substringWithRange:NSMakeRange(i, 1)];
                    NSImage *charImage = [charString imageOfCharacterUsingFont:font textColor:textColor backgroundColor:backgroundColor width:12.0f];
                    if (charImage) {
                        [images addObject:charImage];
                        totalWidth += 12.0f;
                    }
                }
            }
        }
    }
    
    NSArray *charImages = [images copy];
    NSImage *totalImage = [[NSImage alloc] initWithSize:NSMakeSize(totalWidth, 12.0f)];
    [totalImage lockFocus];
    CGFloat x = 0;
    for (NSImage *charImage in charImages) {
        NSSize size = charImage.size;
        [charImage drawAtPoint:NSMakePoint(x, 0) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
        x += size.width;
    }
    [totalImage unlockFocus];
    return totalImage;
}

-(NSImage *)imageOfCharacterUsingFont:(NSFont *)font textColor:(NSColor *)textColor backgroundColor:(NSColor *) backgroundColor width:(CGFloat)width {
    if (!font) font = [NSFont systemFontOfSize:12.0f];
    if (!textColor) textColor = [NSColor blackColor];
    if (!backgroundColor) backgroundColor = [NSColor whiteColor];
    if (width <= 0) width = 12.0f;
    NSRect rect = NSMakeRect(0, 0, width, 12.0f);
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: textColor};
    
    NSImage *image = [[NSImage alloc] initWithSize:rect.size];
    [image lockFocus];
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    context.shouldAntialias = NO;
    [backgroundColor setFill];
    NSRectFill(rect);
    NSSize stringSize = [self sizeWithAttributes:attributes];
    NSPoint startPoint = NSMakePoint((int)((width-stringSize.width)/2), (int)((12.0f-stringSize.height)/2));
    [self drawAtPoint:startPoint withAttributes:attributes];
    [image unlockFocus];
    return image;
}
-(NSImage *)blackWhiteImageOfCharacterUsingFont:(NSFont *)font {
    if (!font) font = [NSFont systemFontOfSize:12.0f];
    NSRect rect = NSMakeRect(0, 0, 12.0f, 12.0f);
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [NSColor blackColor]};
    
    
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                               pixelsWide:12
                                                                               pixelsHigh:12
                                                                            bitsPerSample:8 samplesPerPixel:1
                                                                                 hasAlpha:NO
                                                                                 isPlanar:NO colorSpaceName:NSCalibratedWhiteColorSpace bytesPerRow:12
                                                                             bitsPerPixel:0];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
    [NSGraphicsContext setCurrentContext:context];
    context.shouldAntialias = NO;
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
    NSSize stringSize = [self sizeWithAttributes:attributes];
    NSPoint startPoint = NSMakePoint((int)((12.0f-stringSize.width)/2), (int)((12.0f-stringSize.height)/2));
    [self drawAtPoint:startPoint withAttributes:attributes];
    
    NSImage *resultImage = [[NSImage alloc] initWithSize:rect.size];
    [resultImage lockFocus];
    [bitmapImageRep drawAtPoint:NSZeroPoint];
    [resultImage unlockFocus];
    return resultImage;
}

-(NSData *)LBWDataOfCharacterUsingFont:(NSFont *)font {
    /*
    if ([self isEqualToString:@"兎"]) {
        NSImage *image = [[NSBundle mainBundle] imageForResource:@"dotrabbit"];
        return [image LBWData];
    } else if ([self isEqualToString:@"蛙"]) {
        NSImage *image = [[NSBundle mainBundle] imageForResource:@"dotfrog"];
        return [image LBWData];
    }
     */
    
    if (!font) font = [NSFont systemFontOfSize:12.0f];
    NSRect rect = NSMakeRect(0, 0, 12.0f, 12.0f);
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [NSColor blackColor]};
    
    
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                               pixelsWide:12
                                                                               pixelsHigh:12
                                                                            bitsPerSample:8 samplesPerPixel:1
                                                                                 hasAlpha:NO
                                                                                 isPlanar:NO colorSpaceName:NSCalibratedWhiteColorSpace bytesPerRow:12
                                                                             bitsPerPixel:0];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
    [NSGraphicsContext setCurrentContext:context];
    context.shouldAntialias = NO;
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
    NSSize stringSize = [self sizeWithAttributes:attributes];
    NSPoint startPoint = NSMakePoint((int)((12.0f-stringSize.width)/2), (int)((12.0f-stringSize.height)/2));
    [self drawAtPoint:startPoint withAttributes:attributes];
    
    NSMutableData *resultData = [NSMutableData dataWithCapacity:24];
    for (NSUInteger i=0; i<12; i++) {
        
        // first byte
        unsigned char resultByte1 = 0;
        unsigned char bitMask = 0b10000000;
        for (NSUInteger j=0; j<8; j++) {
            NSUInteger byteOfPoint[1] = {0};
            [bitmapImageRep getPixel:byteOfPoint atX:j y:i];
            if (byteOfPoint[0] == 0) { // black
                resultByte1 = resultByte1 | bitMask;
            }
            bitMask = bitMask >> 1;
        }
        [resultData appendBytes:&resultByte1 length:1];
        
        // second byte
        unsigned char resultByte2 = 0;
        bitMask = 0b10000000;
        for (NSUInteger j=0; j<4; j++) {
            NSUInteger byteOfPoint[1] = {0};
            [bitmapImageRep getPixel:byteOfPoint atX:j+8 y:i];
            if (byteOfPoint[0] == 0) { // black
                resultByte2 = resultByte2 | bitMask;
            }
            bitMask = bitMask >> 1;
        }
        [resultData appendBytes:&resultByte2 length:1];
    }
    return [resultData copy];
}

-(NSArray *)LBWDataArrayOfStringUsingFont:(NSFont *)font {
    
    NSMutableArray *resultArray = [NSMutableArray array];
    NSUInteger location = 0;
    while (location < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:location];
        if (range.length > 0) {
            NSString *subString = [self substringWithRange:range];
            NSData *data = [subString LBWDataOfCharacterUsingFont:font];
            [resultArray addObject:data];
        } else {
            location++;
        }
        location = range.location + range.length;
    }
    return [resultArray copy];
}


@end
