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

- (IBAction)cancel:(id)sender {
	//
}

- (IBAction)startGame:(id)sender {
	[NSNotificationCenter.defaultCenter postNotificationName:[NewGameController newGameNotifName]
													  object:self
													userInfo:@{
															   @"PlayerCount" : @([self.playerCount intValue]),
															   @"TurnCount" : @([self.turnCount intValue])
															   }];
}

+ (NSNotificationName)newGameNotifName {
	return @"com.arc676.Farkle.startGame";
}

@end
