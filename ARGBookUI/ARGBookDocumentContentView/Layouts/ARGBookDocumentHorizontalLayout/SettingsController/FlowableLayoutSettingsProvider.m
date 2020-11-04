//
//  BookContentViewSettings.m
//  Auri
//
//  Created by Fectum on 16/04/16.
//  Copyright © 2016 Argentum. All rights reserved.
//

#import "FlowableLayoutSettingsProvider.h"
#import <ARGBookUI/ARGBookUI-Swift.h>

@interface ARGFlowableLayoutSettingsProvider ()

@property (nonatomic, strong, readonly) NSString *pageSettingsString;

@end

@implementation ARGFlowableLayoutSettingsProvider


- (void)setSettings:(id<ARGBookReadingSettings>)settings completion:(dispatch_block_t)completion {
    __weak typeof (self) wself = self;
    
    [super setSettings:settings completion:^{
        dispatch_group_t settingsGroup = dispatch_group_create();
        
        dispatch_group_notify(settingsGroup, dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
        
        dispatch_group_enter(settingsGroup);
        [wself setRelativePageMargins:UIOffsetMake(settings.horizontalMargin, settings.verticalMargin) completion:^{
            dispatch_group_leave(settingsGroup);
        }];
    }];
}

- (void)setRelativePageMargins:(UIOffset)pageMargins completion:(dispatch_block_t)completion {
    _relativePageMargins = pageMargins;
    
    UIOffset absolutePageMargins = UIOffsetMake(floor(self.webView.bounds.size.width / 100 * pageMargins.horizontal), floor(self.webView.bounds.size.width / 100 * pageMargins.vertical));
    
    [self setAbsolutePageMargins:absolutePageMargins completion:completion];
}

- (void)setAbsolutePageMargins:(UIOffset)pageMargins completion:(dispatch_block_t)completion {
    _absolutePageMargins = pageMargins;
    
    NSString *pageSizeScript = [NSString stringWithFormat:@"setPageSettings(%f, %f, %f, %f, %f, %f)",
                                floor(self.webView.bounds.size.width - pageMargins.horizontal * 2),
                                floor(self.webView.bounds.size.height - pageMargins.vertical * 2),
                                floor(pageMargins.vertical),
                                floor(pageMargins.horizontal),
                                floor(pageMargins.vertical),
                                floor(pageMargins.horizontal)];
    
    if (![pageSizeScript isEqualToString:_pageSettingsString]) {
        _pageSettingsString = pageSizeScript;
        
        [self.webView evaluateJavaScript:pageSizeScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
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

@end
