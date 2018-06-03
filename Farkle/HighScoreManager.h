//
//  HighScoreManager.h
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

#import <Cocoa/Cocoa.h>

@interface HighScoreManager : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *entryTable;
@property (weak) IBOutlet NSTableView *scoresTable;

@property (strong) NSMutableDictionary *scores;
@property (strong) NSArray *entries;
@property (strong) NSDateFormatter *datefmt;

@property (strong) NSAlert* confirmAlert;

+ (NSNotificationName) newGameNotifName;

- (IBAction)deleteSelectedEntry:(id)sender;

- (void) refreshScoreData;
- (void) storeNewGame:(NSNotification*)notif;

@end
