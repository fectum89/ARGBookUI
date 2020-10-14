//
//  BookContentViewSettings.h
//  Auri
//
//  Created by Fectum on 16/04/16.
//  Copyright © 2016 Argentum. All rights reserved.
//

#import "BaseBookContentViewSettingsProvider.h"



@interface FlowableLayoutSettingsProvider : BaseBookContentViewSettingsProvider

@property (nonatomic, assign, readonly) UIOffset         relativePageMargins;
@property (nonatomic, assign, readonly) UIOffset         absolutePageMargins;
@property (nonatomic, assign, readonly) ReadingAlignment alignment;

@end
