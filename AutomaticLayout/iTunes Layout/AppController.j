
@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];
    
    [contentView setBackgroundColor:[CPColor colorWithCalibratedRed:255.0/255.0 green:254.0/255.0 blue:252.0/255.0 alpha:1.0]];
    
    var navigationArea = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, CGRectGetHeight([contentView bounds]) - 150.0)];
    
    [navigationArea setBackgroundColor:[CPColor redColor]];
    
    // Autoresizing Mask
    [navigationArea setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
    
    [contentView addSubview:navigationArea];

    var metaDataArea = [[CPView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([navigationArea frame]), 150.0, 150.0)];
    
    [metaDataArea setBackgroundColor:[CPColor greenColor]];
    
    // Autoresizing Mask
    [metaDataArea setAutoresizingMask:CPViewMinYMargin | CPViewMaxXMargin];
    
    [contentView addSubview:metaDataArea];

    var contentArea = [[CPView alloc] initWithFrame:CGRectMake(150.0, 0.0, CGRectGetWidth([contentView bounds]) - 150.0, CGRectGetHeight([contentView bounds]))];
    
    [contentArea setBackgroundColor:[CPColor blueColor]];
    
    // Autoresizing Mask
    [contentArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    
    [contentView addSubview:contentArea];
    
    [theWindow orderFront:self];
}

@end