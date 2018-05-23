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

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(startGame:)
											   name:[NewGameController newGameNotifName]
											 object:nil];

	self.invalidSelectionAlert = [[NSAlert alloc] init];
	self.invalidSelectionAlert.messageText = @"Cannot select these dice";
	self.invalidSelectionAlert.informativeText = @"The given die selection is invalid";

	self.gameOverAlert = [[NSAlert alloc] init];
	self.gameOverAlert.messageText = @"Game over";
	self.gameOverAlert.informativeText = @"The turn limit has been reached";
	[self.gameOverAlert addButtonWithTitle:@"Save scores"];
	[self.gameOverAlert addButtonWithTitle:@"Discard scores"];

	self.savePanel = [NSSavePanel savePanel];
	self.pCount = 0;

	[self.dieView setVc:self];
}

- (void)startGame:(NSNotification *)notification {
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
	self.pCount = [notification.userInfo[@"PlayerCount"] intValue];
	self.turnLimit = [notification.userInfo[@"TurnCount"] intValue];

	// reset game state
	self.accumulatedPoints = 0;
	self.currentTurn = 1;

	_roll = (Roll*)malloc(sizeof(Roll));
	initRoll(_roll);

	_players = (Player**)malloc(self.pCount * sizeof(Player*));
	_leaderboard = (Player**)malloc(self.pCount * sizeof(Player*));
	for (int i = 0; i < self.pCount; i++) {
		const char* name = [notification.userInfo[@"PlayerNames"][i] cStringUsingEncoding:NSUTF8StringEncoding];
		char* heapName = (char*)malloc(strlen(name));
		memcpy(heapName, name, strlen(name));
		_players[i] = createPlayer(heapName);
		_leaderboard[i] = _players[i];
	}
	[self.dieView setGameState:YES];
	[self enterState:FIRST_ROLL];
	[self.view.window setTitle:[NSString stringWithFormat:@"%s's turn 1 of %d. Score: 0",
								_players[0]->name, self.turnLimit]];
	[self.leaderboardTable reloadData];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (_players) {
		if (tableView == self.leaderboardTable) {
			Player* player = _leaderboard[row];
			if ([tableColumn.title isEqualToString:@"Player Name"]) {
				return [NSString stringWithCString:player->name encoding:NSUTF8StringEncoding];
			} else {
				return @(player->score);
			}
		} else {
			Selection* sel = _players[_currentPlayer]->hand->selections[row];
			if (!sel) {
				return @"";
			}
			if ([tableColumn.title isEqualToString:@"Selection"]) {
				NSMutableArray* nums = [NSMutableArray arrayWithCapacity:6];
				for (int i = 0; i < sel->dieCount; i++) {
					NSNumber* num = [NSNumber numberWithInt:sel->values[i]];
					[nums addObject:num];
				}
				return [nums componentsJoinedByString:@" "];
			} else {
				return [NSString stringWithFormat:@"%d", sel->value];
			}
		}
	}
	return @"";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	if (tableView == self.leaderboardTable) {
		return self.pCount;
	} else {
		if (_players) {
			return _players[_currentPlayer]->hand->timesSelected;
		}
		return 0;
	}
}

- (IBAction)rollDice:(id)sender {
	newRoll(_roll);
	Selection* sel = (Selection*)malloc(sizeof(Selection));
	RollType type = determineRollType(_roll, sel);
	switch (type) {
		case FARKLE:
			emptyHand(_players[_currentPlayer]);
			[self enterState:TURN_ENDED];
			break;
		case STRAIGHT:
		case TRIPLE_PAIR:
			[self updateSelectionValue:sel];
			[self enterState:ROLLING];
			break;
		default:
			[self enterState:PICKING];
			break;
	}
	[self.dieView updateRoll:type];
}

- (IBAction)confirmSelection:(id)sender {
	Selection* sel = (Selection*)malloc(sizeof(Selection));
	if (constructSelection(_roll, sel)) {
		[self enterState:ROLLING];
		[self updateSelectionValue:sel];
	} else {
		[self.invalidSelectionAlert runModal];
		deselectRoll(_roll);
		[self.dieView setNeedsDisplay:YES];
	}
}

- (IBAction)bankPoints:(id)sender {
	bankPoints(_players[_currentPlayer]);
	[self endTurn];
}

- (void)endTurn {
	_currentPlayer = (_currentPlayer + 1) % self.pCount;

	self.accumulatedPoints = 0;
	[self.bankButton setTitle:@"Bank"];

	[self.selectionsTable reloadData];

	initRoll(_roll);
	[self enterState:FIRST_ROLL];

	if (_currentPlayer == 0) {
		self.currentTurn++;
		if (self.currentTurn > self.turnLimit) {
			[self.dieView setGameState:NO];
			if ([self.gameOverAlert runModal] == NSAlertFirstButtonReturn) {
				if ([self.savePanel runModal] == NSFileHandlingPanelOKButton) {
					NSMutableString* str = [NSMutableString string];
					if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePanel.URL.absoluteString]) {
						str = [NSMutableString stringWithContentsOfURL:self.savePanel.URL encoding:NSUTF8StringEncoding error:nil];
						[str appendString:@"\n\n"];
					}
					[str appendFormat:@"%@\n", [NSDate date]];
					for (int i = 0; i < self.pCount; i++) {
						[str appendFormat:@"%s - %d\n", _players[i]->name, _players[i]->score];
					}
					[str writeToURL:self.savePanel.URL atomically:YES encoding:NSUTF8StringEncoding error:nil];
				}
			}
			[self enterState:TURN_ENDED];
			[self.leaderboardTable reloadData];
			[self.view.window setTitle:@"Farkle"];
			return;
		}
	}

	[self.view.window setTitle:[NSString stringWithFormat:@"%s's turn %d of %d. Score: %d",
								_players[_currentPlayer]->name,
								self.currentTurn,
								self.turnLimit,
								_players[_currentPlayer]->score]];

	[self.dieView setNeedsDisplay:YES];

	sortPlayers(_leaderboard, self.pCount);
	[self.leaderboardTable reloadData];
}

- (void)enterState:(GameState)state {
	_state = state;
	self.rollButton.enabled = state & ROLLING;
	self.selectionButton.enabled = state == PICKING;
	self.bankButton.enabled = state == ROLLING;
}

- (void)updateSelectionValue:(Selection *)sel {
	self.accumulatedPoints += sel->value;
	appendSelection(_players[_currentPlayer], sel);
	[self.bankButton setTitle:[NSString stringWithFormat:@"Bank %d points", self.accumulatedPoints]];
	[self.selectionsTable reloadData];
}

@end
