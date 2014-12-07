//
//  THFontWell.m
//  THFontWell
//
//  Created by R. Natori on 06/12/15.
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

#import "THFontWell.h"

static NSMutableArray *__allActiveFontWells = nil;

@implementation THFontWell

#pragma mark -
#pragma mark Object Creation and Destruction
+(void)initialize {
	CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
	arrayCallBacks.retain = NULL;
	arrayCallBacks.release = NULL;
	__allActiveFontWells = (NSMutableArray *)CFBridgingRelease(CFArrayCreateMutable(NULL, 0, &arrayCallBacks));
}

-(id)init {
	self = [super init];
	if (!self) return nil;
	
	[self setFont:[NSFont systemFontOfSize:12.0]];
	[self setButtonType:NSPushOnPushOffButton];
	[self setBezelStyle:NSShadowlessSquareBezelStyle];
	
	return self;
}
-(void)dealloc {
	if ([self isActive]) [self deactivate];
}

#pragma mark -
#pragma mark Accessors 
-(void)setFont:(NSFont *)fontObject {
	[self setTitle:[NSString stringWithFormat:@"%@ - %.0f", [fontObject displayName], [fontObject pointSize]]];
	[super setFont:fontObject];
}

#pragma mark -
#pragma mark Binding
-(void)bind:(NSString *)binding toObject:(id)observableController
withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	if ([binding isEqualToString:@"font"]) {
		_TH_keyPath = keyPath;
		_TH_controller = observableController;
	}
	
	[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}
- (void)unbind:(NSString *)binding {
	if ([binding isEqualToString:@"font"]) {
		_TH_keyPath = nil;
		_TH_controller = nil;
	}
	[super unbind:binding];
}

#pragma mark -
#pragma mark Changing Font
-(void)changeFont:(id)sender{
	NSFont* font = [(NSFontManager *)sender convertFont:[self font]];
	if (!font) return;
	[__allActiveFontWells makeObjectsPerformSelector:@selector(changeEachFont:) withObject:font];
}
-(void)changeEachFont:(NSFont *)font {
	if (_TH_keyPath && _TH_controller) {
		[_TH_controller setValue:font forKeyPath:_TH_keyPath];
	} else {
		[self setFont:font];
	}
	if ([self action]) [super sendAction:[self action] to:[self target]];
}

#pragma mark -
#pragma mark Methods
-(void)awakeFromNib {
	[self setFont:[self font]];
}

-(void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	if ([self isActive]) {
		if ([theEvent modifierFlags] & NSShiftKeyMask) {
			[self deactivate];
			if ([__allActiveFontWells count] > 0) {
				[[__allActiveFontWells lastObject] activate:NO];
			}
		} else {
			[[self class] deactivateAllFontWells];
		}
	} else {
		[self activate:!([theEvent modifierFlags] & NSShiftKeyMask)];
	}
}

-(void)windowWillClose:(NSNotification *)aNotification {
	if ([self isActive]) [self deactivate];
}

-(BOOL)sendAction:(SEL)theAction to:(id)theTarget {
	return YES;
}

-(void)activate:(BOOL)exclusive {
	if (exclusive) [[self class] deactivateAllFontWells];
	if ([__allActiveFontWells indexOfObjectIdenticalTo:self] == NSNotFound) [__allActiveFontWells addObject:self];
	[self setState:NSOnState];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowWillClose:)
												 name:NSWindowWillCloseNotification
											   object:[self window]];
	
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	[fontManager setSelectedFont:[self font] isMultiple:NO];
	[fontManager setAction:@selector(changeFont:)];
    [fontManager orderFrontFontPanel:self];
	
	[[self window] makeFirstResponder:self];
}
-(void)deactivate {
	[__allActiveFontWells removeObjectIdenticalTo:self];
	[self setState:NSOffState];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([[self window] firstResponder] == self) {
		[[self window] makeFirstResponder:nil];
	}
}
+(void)deactivateAllFontWells {
	NSArray *allActiveFontWells = [__allActiveFontWells copy];
	[allActiveFontWells makeObjectsPerformSelector:@selector(deactivate)];
}
-(BOOL)isActive {
	if ([__allActiveFontWells indexOfObjectIdenticalTo:self] != NSNotFound) return YES;
	else return NO;
}
@end
