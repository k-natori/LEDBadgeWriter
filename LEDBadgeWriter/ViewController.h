//
//  ViewController.h
//  LEDBadgeWriter
//
//  Created by 名取 恒平 on 2014/11/01.
//  Copyright (c) 2014年 R. Natori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"

@interface ViewController : NSViewController <ORSSerialPortDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTableView *tableView;
@property (nonatomic, unsafe_unretained) IBOutlet NSArrayController *arrayController;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, unsafe_unretained) IBOutlet NSImageView *imageView;

@property (nonatomic, copy) NSArray *ports;
@property (nonatomic, copy) NSArray *channels;
@property (nonatomic) NSInteger selectedPortIndex;
@property (nonatomic, copy) NSIndexSet *selectedChannelIndexes;

@property (nonatomic) CGFloat progress;
@property (nonatomic) BOOL transferring;

@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, copy) NSArray *waitingPackets;
@property (nonatomic) NSUInteger packetIndex;

@property (nonatomic, copy) NSString *logString;

@property (nonatomic, strong) NSFont *font;


-(IBAction)write:(id)sender ;
-(void)save ;
-(void)logString:(NSString *)string;
-(void)setPortsExceptWireless:(NSArray *)ports ;

-(IBAction)preview:(id)sender ;
@end

