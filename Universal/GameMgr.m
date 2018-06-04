//
//  GameMgr.m
//  Farkle
//
//  Created by Alessandro Vinciguerra on 2018/06/03.
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

#import "GameMgr.h"

@implementation GameMgr

- (void)initializeGame:(int)pCount turns:(int)turnLimit names:(NSArray *)names {
	// free old memory if needed
	if (_roll) {
		free(_roll);
	}
	if (_players) {
		for (int i = 0; i < self.pCount; i++) {
			freePlayer(_players[i]);
		}
		free(_players);
		free(_leaderboard);
	}

	// initialize new game data
	self.pCount = pCount;
	self.turnLimit = turnLimit;

	// reset game state
	self.accumulatedPoints = 0;
	self.currentTurn = 1;

	_roll = (Roll*)malloc(sizeof(Roll));
	initRoll(_roll);

	_players = (Player**)malloc(self.pCount * sizeof(Player*));
	_leaderboard = (Player**)malloc(self.pCount * sizeof(Player*));
	for (int i = 0; i < self.pCount; i++) {
		const char* name = [names[i] cStringUsingEncoding:NSUTF8StringEncoding];
		char* heapName = (char*)malloc(strlen(name));
		memcpy(heapName, name, strlen(name));
		_players[i] = createPlayer(heapName);
		_leaderboard[i] = _players[i];
	}
}

- (void)setupNextTurn {
	_currentPlayer = (_currentPlayer + 1) % self.pCount;
	self.accumulatedPoints = 0;
	initRoll(_roll);
	sortPlayers(_leaderboard, self.pCount);
}

- (NSDictionary *)generateGameData {
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.pCount];
	NSMutableArray *scores = [NSMutableArray arrayWithCapacity:self.pCount];
	for (int i = 0; i < self.pCount; i++) {
		[names addObject:[NSString stringWithCString:_leaderboard[i]->name encoding:NSUTF8StringEncoding]];
		[scores addObject:[NSNumber numberWithInteger:_leaderboard[i]->score]];
	}
	return @{ @"Players" : names, @"Scores" : scores };
}

- (void)updateSelectionValue:(Selection *)sel {
	self.accumulatedPoints += sel->value;
	appendSelection(_players[_currentPlayer], sel);
}

@end
