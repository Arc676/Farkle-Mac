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

#include <stdlib.h>
#include "libfarkle.h"

Roll* roll;
GameState state;
Player** players;

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(startGame:)
											   name:[NewGameController newGameNotifName]
											 object:nil];
}

- (void)startGame:(NSNotification *)notification {
	int pCount = [notification.userInfo[@"PlayerCount"] intValue];
	self.turnLimit = [notification.userInfo[@"TurnCount"] intValue];
	roll = (Roll*)malloc(sizeof(Roll));
	players = (Player**)malloc(pCount * sizeof(Player*));
	for (int i = 0; i < pCount; i++) {
		const char* name = [notification.userInfo[@"PlayerNames"][i] cStringUsingEncoding:NSUTF8StringEncoding];
		players[i] = createPlayer(name);
	}
	[self.dieView startGame];
}

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
	newRoll(roll);
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:6];
	for (int i = 0; i < 6; i++) {
		array[i] = @(roll->dice[i].value);
	}
	[self.dieView setDice:array];
	Selection* sel = (Selection*)malloc(sizeof(Selection));
	RollType type = determineRollType(roll, sel);
	switch (type) {
		case FARKLE:
			printf("Farkle!\n");
			emptyHand(players[self.currentPlayer]);
			[self endTurn];
			break;
		case STRAIGHT:
			printf("Straight!\n");
		case TRIPLE_PAIR:
			if (type != STRAIGHT) {
				printf("Triple pair!\n");
			}
			printf("Selected %d worth of dice.\n", sel->value);
			appendSelection(players[self.currentPlayer], sel);
			state = ROLLING;
			break;
		default:
			state = PICKING;
			break;
	}
}

- (IBAction)confirmSelection:(id)sender {
	Selection* sel = (Selection*)malloc(sizeof(Selection));
	if (constructSelection(roll, sel)) {
		printf("Selected %d points' worth of dice.\n", sel->value);
		state = ROLLING;
		appendSelection(players[self.currentPlayer], sel);
	} else {
		printf("The selection is invalid\n");
		deselectRoll(roll);
	}
}

- (IBAction)bankPoints:(id)sender {
	bankPoints(players[self.currentPlayer]);
	[self endTurn];
}

- (void)endTurn {
	self.currentPlayer++;
}

@end
