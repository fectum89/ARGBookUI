//
//  BookContentViewSettings.h
//  Auri
//
//  Created by Sergei Polshcha on 16/04/16.
//

@import Foundation;
@import WebKit;
@protocol ARGBookReadingSettings;
#import <ARGBookUI/ARGBookReadingSettingsController.h>

@interface ARGFlowableLayoutSettingsController : ARGBookReadingSettingsController

@property (nonatomic, assign, readonly) UIOffset relativePageMargins;
@property (nonatomic, assign, readonly) UIOffset absolutePageMargins;

@end
