//
//  ViewController.m
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

#import "ViewController.h"
#import "LBWChannel.h"
#import "ORSSerialPortManager.h"
#import "NSString+LBWAdditions.h"
#import "NSData+LBWAdditions.h"

@implementation ViewController




-(void)save {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *channelsData = [NSKeyedArchiver archivedDataWithRootObject:self.channels];
    if (channelsData) {
        [standardUserDefaults setObject:channelsData forKey:@"channelsData"];
    } else {
        [standardUserDefaults removeObjectForKey:@"channelsData"];
    }
    
    if (self.font) {
        [standardUserDefaults setObject:self.font.fontName forKey:@"fontName"];
        [standardUserDefaults setFloat:self.font.pointSize forKey:@"fontSize"];
    }
}
-(void)logString:(NSString *)string {
    if (!self.logString) {
        self.logString = [NSString stringWithFormat:@"[%@]:%@", [NSDate date], string];
    } else {
        self.logString = [self.logString stringByAppendingFormat:@"\n[%@]:%@", [NSDate date], string];
    }
    if (self.textView) {
        self.textView.string = self.logString;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load Channels
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *newChannels = nil;
    NSData *channelsData = [standardUserDefaults objectForKey:@"channelsData"];
    if (channelsData) {
     newChannels = [NSKeyedUnarchiver unarchiveObjectWithData:channelsData];
    }
    
    if (!newChannels) {
        newChannels = @[[LBWChannel channelWithString:@"text 1"],
                        [LBWChannel channelWithString:@"text 2"],
                        [LBWChannel channelWithString:@"text 3"],
                        [LBWChannel channelWithString:@"text 4"],
                        [LBWChannel channelWithString:@"text 5"],
                        [LBWChannel channelWithString:@"text 6"],
                        [LBWChannel channelWithString:@"text 7"],
                        [LBWChannel channelWithString:@"text 8"]];
    } else if (newChannels.count < 8) {
        newChannels = @[[LBWChannel channelWithString:@"text 1"],
                        [LBWChannel channelWithString:@"text 2"],
                        [LBWChannel channelWithString:@"text 3"],
                        [LBWChannel channelWithString:@"text 4"],
                        [LBWChannel channelWithString:@"text 5"],
                        [LBWChannel channelWithString:@"text 6"],
                        [LBWChannel channelWithString:@"text 7"],
                        [LBWChannel channelWithString:@"text 8"]];
    }
    self.channels = newChannels;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
    
    // Load Ports
    [self setPortsExceptWireless: [[ORSSerialPortManager sharedSerialPortManager] availablePorts]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portsChanged:) name:ORSSerialPortsWereConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(portsChanged:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
    
    // config views
    /*
    self.textView.font = [NSFont fontWithName:@"Osaka" size:12.0f];
    self.textView.layoutManager.usesScreenFonts = YES;
    */
    
    NSString *fontName = [standardUserDefaults objectForKey:@"fontName"];
    CGFloat fontSize = [standardUserDefaults floatForKey:@"fontSize"];
    self.font = [NSFont fontWithName:fontName size:fontSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewSelectionDidChange:) name:
     NSTableViewSelectionDidChangeNotification object:self.tableView];

}

-(void)appWillTerminate:(NSNotification *)notification {
    [self.view.window.firstResponder resignFirstResponder];
    [self save];
}

-(void)portsChanged:(NSNotification *)notification {
    [self setPortsExceptWireless: [[ORSSerialPortManager sharedSerialPortManager] availablePorts]];
    if (self.selectedPortIndex >= self.ports.count) {
        self.selectedPortIndex = 0;
    }
}

-(void)setPortsExceptWireless:(NSArray *)ports {
    NSMutableArray *newPorts = [NSMutableArray array];
    for (ORSSerialPort *port in ports) {
        if ([port.name rangeOfString:@"Bluetooth"].location == NSNotFound &&
              [port.name rangeOfString:@"Wireless"].location == NSNotFound) {
            [newPorts addObject:port];
        }
    }
    self.ports = [newPorts copy];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(IBAction)write:(id)sender {
    
    [self.view.window.firstResponder resignFirstResponder];
    self.logString = @"";
    self.textView.string = @"";
    
    if (self.channels.count > 8) {
        self.channels = [self.channels subarrayWithRange:NSMakeRange(0, 8)];
    }
    
    NSMutableArray *allPackets = [NSMutableArray array];
    NSUInteger channelIndex = 0;
    unsigned char enabledChannelFlag = 0b00000000;
    unsigned char currentChannelFlag = 0b00000001;
    
    // Extended Char Set;
    NSMutableOrderedSet *tempExtendedCharactersSet = [NSMutableOrderedSet orderedSet];
    
    for (LBWChannel *channel in self.channels) {
        if (channel.enabled) {
            NSArray *dataArray = [channel dataArrayForExtendedCharactersUsingFont:self.font];
            [tempExtendedCharactersSet addObjectsFromArray:dataArray];
        }
    }
    if (tempExtendedCharactersSet.count > 256) {
        [tempExtendedCharactersSet removeObjectsInRange:NSMakeRange(256, tempExtendedCharactersSet.count- 256)];
    }
    NSOrderedSet *extendedCharactersSet = [tempExtendedCharactersSet copy];
    
    // Text Data Packets for channels
    for (LBWChannel *channel in self.channels) {
        channel.channel = channelIndex;
        
        if (channel.enabled) {
            NSArray *tempPackets = [channel packetsUsingExtendedCharactersSet:extendedCharactersSet usingFont:self.font];
            if (tempPackets) {
                [allPackets addObjectsFromArray:tempPackets];
                enabledChannelFlag = enabledChannelFlag | currentChannelFlag;
            }
        }
        
        channelIndex++;
        currentChannelFlag = currentChannelFlag << 1;
        
    }
    
    // Font Data Packets
    NSMutableData *allFontData = [NSMutableData data];
    for (NSData *oneFontData in extendedCharactersSet) {
        [allFontData appendData:oneFontData];
    }
    NSArray *fontDataPackets = [[allFontData copy] packetsFromAddress:0x0e00];
    [allPackets addObjectsFromArray:fontDataPackets];
    
    if (allPackets.count == 0) return;
    
    // terminate packet
    unsigned char footer[4];
    footer[0] = 2;
    footer[1] = '3';
    footer[2] = enabledChannelFlag;
    footer[3] = ((NSUInteger)(footer[1]) + (NSUInteger)footer[2]) % 256;;
    NSData *footerData = [NSData dataWithBytes:footer length:4];
    [allPackets addObject:footerData];
    
    self.waitingPackets = [allPackets copy];
    self.packetIndex = 0;
    self.progress = 0;
    self.transferring = YES;
    
    if (self.ports.count > 0) {
        self.serialPort = [self.ports objectAtIndex:self.selectedPortIndex];
        
        if (self.serialPort) {
            self.serialPort.delegate = self;
            self.serialPort.baudRate = [NSNumber numberWithUnsignedInt:38400];
            self.serialPort.numberOfStopBits = 1;
            self.serialPort.parity = ORSSerialPortParityNone;
            [self.serialPort open];
            return;
        }
    }
    [self logString:@"test mode opened."];
    [self sendNextPacket:nil];
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort {
    
    [self logString:@"opened."];
    [self sendNextPacket:nil];

}

-(void)sendNextPacket:(NSTimer *)timer {
    [timer invalidate];
    
    unsigned char startByte = 0x00;
    NSData *startData = [NSData dataWithBytes:&startByte length:1];
    
    BOOL success = NO;
    if (self.serialPort && self.packetIndex == 0) success = [self.serialPort sendData:startData];
    
    NSData *packetData = [self.waitingPackets objectAtIndex:self.packetIndex];
    if (self.serialPort) success = [self.serialPort sendData:packetData];
    [self logString:[NSString stringWithFormat:@"%d, %@, %lu bytes", success, packetData, (unsigned long)packetData.length]];
    
    self.packetIndex = self.packetIndex +1;
    self.progress = (CGFloat)(self.packetIndex) / (CGFloat)(self.waitingPackets.count);
    if (self.packetIndex >= self.waitingPackets.count) {
        [self.serialPort close];
        self.transferring = NO;
        return;
    }
    
    NSTimeInterval timeInterval = 0.3;
    if (self.packetIndex == 1) timeInterval = 0.5;
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(sendNextPacket:) userInfo:nil repeats:NO];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort {
    if (self.serialPort == serialPort) {
        self.serialPort = nil;
        [self logString:@"removed."];
    }
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort {
    [self logString:@"closed."];
    self.serialPort = nil;
}

#pragma mark - Preview
-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSUInteger index = self.arrayController.selectionIndex;
    if (index == NSNotFound) return;
    LBWChannel *channel = [self.channels objectAtIndex:index];
    NSString *string = channel.string;
    if (string) {
        NSImage *previewImage = [string imageOfStringUsingFont:self.font textColor:[NSColor redColor] backgroundColor:[NSColor blackColor]];
        NSSize size = previewImage.size;
        previewImage.size = NSMakeSize(size.width*4, size.height*4);
        self.imageView.frame = NSMakeRect(0, 0, previewImage.size.width, previewImage.size.height);
        self.imageView.image = previewImage;
        [self.imageView setNeedsDisplay];
        
    }
}
-(IBAction)preview:(id)sender {
}

@end
