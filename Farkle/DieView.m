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

- (void)awakeFromNib {
	NSMutableArray* textures = [NSMutableArray arrayWithCapacity:6];
	for (int i = 1; i <= 6; i++) {
		textures[i - 1] = [NSImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
	}
	self.textures = [textures copy];
	self.points = @[
					@"30 147",
					@"130 147",
					@"30 81",
					@"130 81",
					@"30 15",
					@"130 15"
					];
	self.gameStarted = NO;
	[super awakeFromNib];
}

- (void)startGame {
	self.gameStarted = YES;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	if (self.gameStarted) {
		[self.userFeedback drawAtPoint:NSMakePoint(20, 210) withAttributes:nil];
		for (int i = 0; i < 6; i++) {
			Die die = self.vc.roll->dice[i];
			if (die.value != 0) {
//				if (die.picked) {
					[(NSImage*)self.textures[die.value - 1] drawAtPoint:NSPointFromString(self.points[i])
															   fromRect:NSZeroRect
															  operation:NSCompositeSourceOver
															   fraction:1.0f];
//				}
			}
		}
	} else {
		[@"No game in\nprogress" drawAtPoint:NSMakePoint(60, 100) withAttributes:nil];
	}
}

- (void)updateRoll:(RollType)type {
	switch (type) {
		case FARKLE:
			self.userFeedback = @"Farkle!";
			break;
		case STRAIGHT:
			self.userFeedback = @"Straight!";
			break;
		case TRIPLE_PAIR:
			self.userFeedback = @"Triple pair!";
			break;
		default:
			self.userFeedback = @"";
			break;
	}
	[self setNeedsDisplay:YES];
}

@end
