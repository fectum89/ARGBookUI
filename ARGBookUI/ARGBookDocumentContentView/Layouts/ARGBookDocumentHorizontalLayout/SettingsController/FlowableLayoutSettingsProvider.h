//
//  BookContentViewSettings.h
//  Auri
//
//  Created by Fectum on 16/04/16.
//  Copyright © 2016 Argentum. All rights reserved.
//

@import Foundation;
@import WebKit;
@protocol ARGBookReadingSettings;
#import <ARGBookUI/ARGBookReadingSettingsController.h>

@interface ARGFlowableLayoutSettingsProvider : ARGBookReadingSettingsController

@property (nonatomic, assign, readonly) UIOffset         relativePageMargins;
@property (nonatomic, assign, readonly) UIOffset         absolutePageMargins;

@end
