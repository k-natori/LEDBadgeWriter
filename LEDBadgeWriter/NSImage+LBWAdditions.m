//
//  NSImage+LBWAdditions.m
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/22.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import "NSImage+LBWAdditions.h"

@implementation NSImage (NSImage_LBWAdditions)
-(NSData *)LBWData {
    NSRect rect = NSMakeRect(0, 0, 12.0f, 12.0f);
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
    
    [self drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0f];
    
    NSMutableData *resultData = [NSMutableData dataWithCapacity:24];
    for (NSUInteger i=0; i<12; i++) {
        
        // first byte
        unsigned char resultByte1 = 0;
        unsigned char bitMask = 0b10000000;
        for (NSUInteger j=0; j<8; j++) {
            NSUInteger byteOfPoint[1] = {0};
            [bitmapImageRep getPixel:byteOfPoint atX:j y:i];
            if (byteOfPoint[0] < 100) { // black
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
            if (byteOfPoint[0] < 100) { // black
                resultByte2 = resultByte2 | bitMask;
            }
            bitMask = bitMask >> 1;
        }
        [resultData appendBytes:&resultByte2 length:1];
    }
    return [resultData copy];
}

@end
