//
//  NSData+LBWAdditions.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/17.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_LBWAdditions)
-(NSArray *)packetsFromAddress:(UInt16)address;
@end
