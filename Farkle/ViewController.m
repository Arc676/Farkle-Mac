//
//  ViewController.m
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

#import "ViewController.h"

#include "libfarkle.h"

Roll* roll;
GameState state;
Player** players;

@implementation ViewController

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (players) {
		NSMutableArray* nums = [NSMutableArray arrayWithCapacity:6];
		Selection* sel = players[self.currentPlayer]->hand->selections[row];
		for (int i = 0; i < sel->dieCount; i++) {
			NSNumber* num = [NSNumber numberWithInt:sel->values[i]];
			[nums addObject:num];
		}
		return [nums componentsJoinedByString:@" "];
	}
	return @"";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	if (players) {
		return players[self.currentPlayer]->hand->timesSelected;
	}
	return 0;
}

- (IBAction)rollDice:(id)sender {
}

- (IBAction)confirmSelection:(id)sender {
}

- (IBAction)bankPoints:(id)sender {
}

@end
