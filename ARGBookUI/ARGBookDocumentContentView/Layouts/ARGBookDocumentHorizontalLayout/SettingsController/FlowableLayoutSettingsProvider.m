//
//  BookContentViewSettings.m
//  Auri
//
//  Created by Fectum on 16/04/16.
//  Copyright © 2016 Argentum. All rights reserved.
//

#import "FlowableLayoutSettingsProvider.h"
#import "BaseBookContentView.h"

@interface FlowableLayoutSettingsProvider ()

@property (nonatomic, strong, readonly) NSString *pageSettingsString;

@end

@implementation FlowableLayoutSettingsProvider

- (void)setSettings:(ReadingSettings *)settings completion:(ObjectBlock)completion {
    __weak typeof (self) wself = self;
    
    [super setSettings:settings completion:^(WKWebView *webView) {
        dispatch_group_t settingsGroup = dispatch_group_create();
        
        dispatch_group_notify(settingsGroup, dispatch_get_main_queue(), ^{
            if (completion) {
                completion(webView);
            }
        });
        
        dispatch_group_enter(settingsGroup);
        [wself setRelativePageMargins:UIOffsetMake(settings.horizontalMargin, settings.verticalMargin) completion:^{
            dispatch_group_leave(settingsGroup);
        }];
        
        dispatch_group_enter(settingsGroup);
        [wself setAlignment:settings.alignment completion:^{
            dispatch_group_leave(settingsGroup);
        }];
        
//        [wself setRelativePageMargins:UIOffsetMake(settings.horizontalMargin, settings.verticalMargin) completion:^{
//            [wself setAlignment:settings.alignment completion:^{
//                if (completion) {
//                    completion(webView);
//                }
//            }];
//        }];
    }];
}

- (void)setRelativePageMargins:(UIOffset)pageMargins completion:(dispatch_block_t)completion {
    _relativePageMargins = pageMargins;
    
    UIOffset absolutePageMargins = UIOffsetMake(floor(self.contentView.width / 100 * pageMargins.horizontal), floor(self.contentView.height / 100 * pageMargins.vertical));
    
    [self setAbsolutePageMargins:absolutePageMargins completion:completion];
}

- (void)setAbsolutePageMargins:(UIOffset)pageMargins completion:(dispatch_block_t)completion {
    _absolutePageMargins = pageMargins;
    
    NSString *pageSizeScript = [NSString stringWithFormat:@"setPageSettings(%f, %f, %f, %f, %f, %f)",
                                floor(self.contentView.width - pageMargins.horizontal * 2),
                                floor(self.contentView.height - pageMargins.vertical * 2),
                                floor(pageMargins.vertical),
                                floor(pageMargins.horizontal),
                                floor(pageMargins.vertical),
                                floor(pageMargins.horizontal)];
    
    if (![pageSizeScript isEqualToString:_pageSettingsString]) {
        _pageSettingsString = pageSizeScript;
        
        [self.contentView evaluateScript:pageSizeScript withCompletion:^(id obj) {
            if (completion) {
                completion();
            }
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)setAlignment:(ReadingAlignment)alignment completion:(dispatch_block_t)completion {
    if (_alignment == alignment) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _alignment = alignment;
    
    NSString *alignmentString = nil;
    
    if (alignment == ReadingAlignmentLeft) {
        alignmentString = @"left";
    } else if (alignment == ReadingAlignmentJustify) {
        alignmentString = @"justify";
    }
    
    [self.contentView evaluateScript:[NSString stringWithFormat:@"setTextAlignment('%@')", alignmentString] withCompletion:^(id obj) {
        if (completion) {
            completion();
        }
    }];
}

@end
