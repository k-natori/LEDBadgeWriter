//
//  LBWBoard.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/12/06.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBWBoard : NSObject

@property (nonatomic, copy) NSArray *channels;
@property (nonatomic, strong) NSFont *font;

@property (nonatomic, copy) NSDictionary *imagesForCharacters;

-(NSArray *)packets ;
@end
