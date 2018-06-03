//
//  HighScoreManager.m
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

#import "HighScoreManager.h"

@implementation HighScoreManager

- (void)viewDidLoad {
	[super viewDidLoad];
	NSDictionary* existing = [NSKeyedUnarchiver
							  unarchiveObjectWithData:
							  [NSUserDefaults.standardUserDefaults objectForKey:@"HighScores"]];
	self.scores = existing ? [existing mutableCopy] : [NSMutableDictionary dictionary];
	[self refreshScoreData];

	self.datefmt = [[NSDateFormatter alloc] init];
	self.datefmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";

	self.confirmAlert = [[NSAlert alloc] init];
	self.confirmAlert.messageText = @"Confirm deletion";
	self.confirmAlert.informativeText = @"Are you sure you want to delete? This cannot be undone.";
	[self.confirmAlert addButtonWithTitle:@"Yes"];
	[self.confirmAlert addButtonWithTitle:@"Cancel"];

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(storeNewGame:)
											   name:[HighScoreManager newGameNotifName]
											 object:nil];
}

- (void)refreshScoreData {
	self.entries = [[self.scores allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate  *d2) {
		return [d2 compare:d1];
	}];
	[self.entryTable reloadData];
	[self.scoresTable reloadData];
}

- (IBAction)deleteSelectedEntry:(id)sender {
	NSInteger row = [self.entryTable selectedRow];
	if (row != -1 && [self.confirmAlert runModal] == NSAlertFirstButtonReturn) {
		[self.scores removeObjectForKey:self.entries[row]];
		[self saveScoresToDisk];
		[self refreshScoreData];
	}
}

- (IBAction)deleteAllEntries:(id)sender {
	if ([self.confirmAlert runModal] == NSAlertFirstButtonReturn) {
		[self.scores removeAllObjects];
		[self saveScoresToDisk];
		[self refreshScoreData];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	if (notification.object == self.entryTable) {
		[self.scoresTable reloadData];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	if (tableView == self.entryTable) {
		return [self.scores count];
	} else {
		NSInteger row = [self.entryTable selectedRow];
		if (row != -1) {
			return [self.scores[self.entries[row]][@"Players"] count];
		}
		return 0;
	}
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (tableView == self.entryTable) {
		return [self.datefmt stringFromDate:self.entries[row]];
	} else {
		NSInteger entryRow = [self.entryTable selectedRow];
		if (entryRow != -1) {
			NSDictionary *gameScores = self.scores[self.entries[entryRow]];
			if ([tableColumn.title isEqualToString:@"Score"]) {
				return gameScores[@"Scores"][row];
			} else {
				return gameScores[@"Players"][row];
			}
		}
		return @"";
	}
}

- (void)saveScoresToDisk {
	[NSUserDefaults.standardUserDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.scores]
											forKey:@"HighScores"];
}

- (void)storeNewGame:(NSNotification *)notif {
	self.scores[[NSDate date]] = notif.userInfo;
	[self saveScoresToDisk];
	[self refreshScoreData];
}

+ (NSNotificationName)newGameNotifName {
	return @"com.arc676.Farkle.storeNewScores";
}

@end
