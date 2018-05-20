//
//  NewGameController.m
//  Farkle
//
//  Created by Alessandro Vinciguerra on 2018/05/20.
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

#import "NewGameController.h"

@implementation NewGameController

- (void)viewDidLoad {
	self.pCount = 1;
	self.playerNames = [NSMutableArray arrayWithCapacity:5];
	self.playerNames[0] = @"Player 1";
}

- (IBAction)changePlayerCount:(NSTextField *)sender {
	int newCount = [self.playerCount intValue];
	if (newCount <= 0) {
		[self.playerCount setIntValue:self.pCount];
		return;
	}
	for (int i = self.pCount; i < newCount; i++) {
		[self.playerNames addObject:[NSString stringWithFormat:@"Player %d", i + 1]];
	}
	self.pCount = newCount;
	[self.nameTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return self.pCount;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return YES;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	self.playerNames[row] = (NSString*)object;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return self.playerNames[row];
}

- (IBAction)cancel:(id)sender {
	[self.view.window setIsVisible:NO];
}

- (IBAction)startGame:(id)sender {
	int turns = [self.turnCount intValue];
	if (turns <= 0) {
		return;
	}
	[NSNotificationCenter.defaultCenter postNotificationName:[NewGameController newGameNotifName]
													  object:self
													userInfo:@{
															   @"PlayerCount" : @(self.pCount),
															   @"TurnCount" : @(turns),
															   @"PlayerNames" : self.playerNames
															   }];
	[self.view.window setIsVisible:NO];
}

+ (NSNotificationName)newGameNotifName {
	return @"com.arc676.Farkle.startGame";
}

@end
