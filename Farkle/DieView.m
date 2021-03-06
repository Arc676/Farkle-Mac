//
//  DieView.m
//  Farkle
//
//  Created by Alessandro Vinciguerra on 2018/05/19.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3) with the exception that
//linking Apple libraries is allowed to the extent to which this is necessary
//for compilation

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

#import "DieView.h"
#import "ViewController.h"

@implementation DieView

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)awakeFromNib {
	NSMutableArray* textures = [NSMutableArray arrayWithCapacity:6];
	for (int i = 1; i <= 6; i++) {
		textures[i - 1] = [NSImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
	}
	self.textures = [textures copy];
	self.points = @[
					@"30 147",
					@"30 81",
					@"30 15",
					@"130 147",
					@"130 81",
					@"130 15"
					];
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:6];
	for (NSString* p in self.points) {
		NSPoint point = NSPointFromString(p);
		[array addObject:[NSString stringWithFormat:@"%d %d %d %d",
						  (int)point.x - 5, (int)point.y - 5, 42, 42]];
	}
	self.rects = [array mutableCopy];
	self.pickable = [@[@NO, @NO, @NO, @NO, @NO, @NO] mutableCopy];
	self.gameStarted = NO;
	self.hasFarkled = NO;

	self.rollSound = [NSSound soundNamed:@"roll.wav"];
	self.farkleSound = [NSSound soundNamed:@"farkle.wav"];
	self.tickSound = [NSSound soundNamed:@"tick.wav"];
	self.tpairSound = [NSSound soundNamed:@"tpair.wav"];
	self.straightSound = [NSSound soundNamed:@"straight.wav"];

	[super awakeFromNib];
}

- (void)setGameState:(BOOL)inProgress {
	self.gameStarted = inProgress;
	[self setNeedsDisplay:YES];
	self.userFeedback = @"";
}

- (void)drawRect:(NSRect)rect {
	if (self.gameStarted) {
		[self.userFeedback drawAtPoint:NSMakePoint(20, 200) withAttributes:nil];
		for (int i = 0; i < 6; i++) {
			Die die = self.vc.roll->dice[i];
			if (die.value != 0) {
				NSPoint point = NSPointFromString(self.points[i]);
				NSImage* dieTexture = (NSImage*)self.textures[die.value - 1];
				if (die.picked && !die.pickedThisRoll) {
					[dieTexture drawAtPoint:point
								   fromRect:NSZeroRect
								  operation:NSCompositeSourceOver
								   fraction:0.5f];
				} else {
					if (![self.pickable[i] boolValue] || die.pickedThisRoll) {
						if (die.pickedThisRoll) {
							[[NSColor greenColor] set];
						} else {
							[[NSColor redColor] set];
						}
						NSRectFill(NSRectFromString(self.rects[i]));
					}
					[dieTexture drawAtPoint:point
								   fromRect:NSZeroRect
								  operation:NSCompositeSourceOver
								   fraction:1.0f];
				}
			}
		}
	} else {
		[@"No game in\nprogress" drawAtPoint:NSMakePoint(60, 100) withAttributes:nil];
	}
}

- (void)updateRoll:(RollType)type {
	self.hasFarkled = NO;
	int values[6];
	countDiceValues(self.vc.roll, values);
	int pickableDice[6];
	determinePickableDice(self.vc.roll, values, pickableDice);
	switch (type) {
		case FARKLE:
			[self.farkleSound play];
			self.userFeedback = @"Farkle! Click on the board or\npress space to pass the turn.";
			self.hasFarkled = YES;
			break;
		case STRAIGHT:
			[self.straightSound play];
			self.userFeedback = @"Straight!";
		case TRIPLE_PAIR:
			if (type != STRAIGHT) {
				[self.tpairSound play];
				self.userFeedback = @"Triple pair!";
			}
			for (int i = 0; i < 6; i++) {
				pickableDice[i] = 1;
			}
			break;
		default:
			[self.rollSound play];
			self.userFeedback = @"";
			break;
	}
	for (int i = 0; i < 6; i++) {
		self.pickable[i] = @(pickableDice[i] > 0);
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
	if (!(self.vc.state & (PICKING | TURN_ENDED))) {
		return;
	}
	if (self.hasFarkled) {
		self.userFeedback = @"";
		self.hasFarkled = NO;
		[self.vc endTurn];
		return;
	}
	int i = 0;
	NSPoint loc = [self convertPoint:event.locationInWindow fromView:nil];
	for (NSString* r in self.rects) {
		if (NSPointInRect(loc, NSRectFromString(r))) {
			[self toggle:i];
			return;
		}
		i++;
	}
}

- (void)keyDown:(NSEvent *)event {
	int i = [event.characters intValue];
	if (!(i >= 1 && i <= 6)) {
		[super keyDown:event];
	}
}

- (void)keyUp:(NSEvent *)event {
	if (self.vc.state == PICKING) {
		int i = [event.characters intValue];
		if (i >= 1 && i <= 6) {
			[self toggle:i - 1];
		}
	} else if (self.hasFarkled && event.keyCode == 49) {
		self.userFeedback = @"";
		[self.vc endTurn];
	}
}

- (void)toggle:(int)index {
	switch (toggleDie(self.vc.roll, index)) {
		case PICKED:
		case UNPICKED:
			[self.tickSound play];
			[self setNeedsDisplay:YES];
			break;
		default:
			break;
	}
}

@end
