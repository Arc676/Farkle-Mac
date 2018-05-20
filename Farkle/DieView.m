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

@implementation DieView

- (instancetype)init {
	self = [super init];
	if (self) {
		NSMutableArray* textures = [NSMutableArray arrayWithCapacity:6];
		for (int i = 1; i <= 6; i++) {
			textures[i - 1] = [NSImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
		}
		self.textures = [textures copy];
		self.dice = @[@0, @0, @0, @0, @0, @0];
		self.gameStarted = NO;
	}
	return self;
}

- (void)startGame {
	self.gameStarted = YES;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	if (self.gameStarted) {
	} else {
		[@"No game in\nprogress" drawAtPoint:NSMakePoint(60, 100) withAttributes:nil];
	}
}

@end
