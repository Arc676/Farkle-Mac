//
//  ViewController.h
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

#import "GameMgr.h"

#import "DieView.h"
#import "NewGameController.h"
#import "HighScoreManager.h"

@interface ViewController : GameMgr <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *selectionsTable;
@property (weak) IBOutlet NSTableView *leaderboardTable;

@property (weak) IBOutlet DieView *dieView;
@property (strong) NSSound *bankSound;

@property (weak) IBOutlet NSButton *rollButton;
@property (weak) IBOutlet NSButton *selectionButton;
@property (weak) IBOutlet NSButton *bankButton;

@property (strong) NSAlert *invalidSelectionAlert;
@property (strong) NSAlert *gameOverAlert;
@property (strong) NSSavePanel *savePanel;

- (void) startGame:(NSNotification*)notification;
- (void) enterState:(GameState)state;

- (void) endTurn;

- (IBAction)rollDice:(id)sender;
- (IBAction)confirmSelection:(id)sender;
- (IBAction)bankPoints:(id)sender;

@end

