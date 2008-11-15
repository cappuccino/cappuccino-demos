//
// AppController.j
// Scrapbook
//
// Created by Francisco Tolmasky.
//

@import <Foundation/CPObject.j>

@import "PageView.j"
@import "PhotoInspector.j"
@import "PhotoPanel.j"


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    [contentView setBackgroundColor:[CPColor blackColor]];
    
    [theWindow orderFront:self];

    var bounds = [contentView bounds],
        pageView = [[PageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(bounds) / 2.0 - 200.0, CGRectGetHeight(bounds) / 2.0 - 200.0, 400.0, 400.0)];

    [pageView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

    [contentView addSubview:pageView];
    
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    
    [label setTextColor:[CPColor whiteColor]];
    [label setStringValue:@"Double Click to Edit Photo"];
    
    [label sizeToFit];
    [label setFrameOrigin:CGPointMake(CGRectGetWidth(bounds) / 2.0 - CGRectGetWidth([label frame]) / 2.0, CGRectGetMinY([pageView frame]) - CGRectGetHeight([label frame]))];
    [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    
    [contentView addSubview:label];
    
    [[[PhotoPanel alloc] init] orderFront:nil];
}

@end
