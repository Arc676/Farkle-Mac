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

@synthesize roll=_roll;
@synthesize players=_players;
@synthesize state=_state;
@synthesize leaderboard=_leaderboard;
@synthesize currentTurn=_currentTurn;
@synthesize currentPlayer=_currentPlayer;

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
	[super initializeGame:[notification.userInfo[@"PlayerCount"] intValue]
					turns:[notification.userInfo[@"PlayerCount"] intValue]
					names:notification.userInfo[@"PlayerNames"]];

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
	[self.bankButton setTitle:@"Bank"];
	[self enterState:FIRST_ROLL];
	[self.selectionsTable reloadData];
	[self.leaderboardTable reloadData];

	if (_currentPlayer == 0) {
		self.currentTurn++;
		if (self.currentTurn > self.turnLimit) {
			[self.dieView setGameState:NO];

			[NSNotificationCenter.defaultCenter postNotificationName:[HighScoreManager newGameNotifName]
															  object:self
															userInfo:[super generateGameData]];
			[self enterState:TURN_ENDED];
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
}

- (void)enterState:(GameState)state {
	_state = state;
	self.rollButton.enabled = state & ROLLING;
	self.selectionButton.enabled = state == PICKING;
	self.bankButton.enabled = state == ROLLING;
}

- (void)updateSelectionValue:(Selection *)sel {
	[super updateSelectionValue:sel];
	[self.bankButton setTitle:[NSString stringWithFormat:@"Bank %d points", self.accumulatedPoints]];
	[self.selectionsTable reloadData];
}

@end
