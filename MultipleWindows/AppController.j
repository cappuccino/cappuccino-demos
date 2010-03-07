/*
 * AppController.j
 *
 * Created by Francisco Tolmasky.
 */

@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [self showWindowWithContentRect:CGRectMake(50, 50, 400, 400) styleMask:CPBorderlessBridgeWindowMask name:@"Main Window"];
    [self showWindowWithContentRect:CGRectMake(600.0, 100.0, 400.0, 300.0) styleMask:CPTitledWindowMask | CPResizableWindowMask | CPClosableWindowMask name:@"Standard Window"];
    [self showWindowWithContentRect:CGRectMake(100.0, 100.0, 400.0, 300.0) styleMask:CPTitledWindowMask | CPResizableWindowMask | CPHUDBackgroundWindowMask name:@"HUD Window"];
    
    // Uncomment the following line to turn on the standard menu bar.
    [CPMenu setMenuBarVisible:YES];
}

- (void)showWindowWithContentRect:(CGRect)aContentRect styleMask:(unsigned)aStyleMask name:(CPString)aName
{
    var theWindow = [[CPWindow alloc] initWithContentRect:aContentRect styleMask:aStyleMask],
        contentView = [theWindow contentView];
        
    [theWindow setTitle:@"Window"];
    
    [theWindow orderFront:self];
    
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];

    [label setStringValue:aName];
    [label setTextColor:aStyleMask & CPHUDBackgroundWindowMask ? [CPColor whiteColor] : [CPColor blackColor]];
    [label setFont:[CPFont boldSystemFontOfSize:24.0]];

    [label sizeToFit];

    [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin];
    [label setFrameOrigin:CGPointMake((CGRectGetWidth([contentView bounds]) - CGRectGetWidth([label frame])) / 2.0, 80.0)];
    
    [contentView addSubview:label];
    
    var toggleToolbarButton = [[CPButton alloc] initWithFrame:CGRectMake((CGRectGetWidth([contentView bounds]) - 100.0) / 2.0, CGRectGetMaxY([label frame]) + 10.0, 100.0, 24.0)];
    
    [toggleToolbarButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin];
    [toggleToolbarButton setTitle:@"Toggle Toolbar"];
    [toggleToolbarButton setTarget:theWindow];
    [toggleToolbarButton setAction:@selector(toggleToolbarShown:)];
    
    [contentView addSubview:toggleToolbarButton];
    
    var toggleFullBridgeButton = [[CPButton alloc] initWithFrame:CGRectMake((CGRectGetWidth([contentView bounds]) - 120.0) / 2.0, CGRectGetMaxY([toggleToolbarButton frame]) + 10.0, 120.0, 24.0)];

    [toggleFullBridgeButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin];
    [toggleFullBridgeButton setTitle:@"Toggle Full Bridge"];
    [toggleFullBridgeButton setTarget:nil];
    [toggleFullBridgeButton setAction:@selector(toggleFullBridge:)];
    
    [contentView addSubview:toggleFullBridgeButton];
    
    var toolbar = [[CPToolbar alloc] initWithIdentifier:@"Toolbar"];
    
    [toolbar setDelegate:self];
    [theWindow setToolbar:toolbar];
}

- (void)toggleFullBridge:(id)aSender
{
    [[aSender window] setFullBridge:![[aSender window] isFullBridge]];
}

@end



var PopUpButtonToolbarItemIdentifier    = @"PopUpButtonToolbarItemIdentifier",
    SliderToolbarItemIdentifier         = @"SliderToolbarItemIdentifier",
    ButtonToolbarItemIdentifier         = @"ButtonToolbarItemIdentifier";

@implementation AppController (Toolbar)

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
    return [
        PopUpButtonToolbarItemIdentifier, SliderToolbarItemIdentifier,
        ButtonToolbarItemIdentifier,
        CPToolbarSeparatorItemIdentifier, CPToolbarSpaceItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
    return [
        
        ButtonToolbarItemIdentifier,
        
        CPToolbarSeparatorItemIdentifier,
        
        CPToolbarSpaceItemIdentifier,
        
        PopUpButtonToolbarItemIdentifier, SliderToolbarItemIdentifier,
        
        CPToolbarSpaceItemIdentifier
        ];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    
    [toolbarItem setTarget:self];
    [toolbarItem setMinSize:CGSizeMake(32.0, 32.0)];
    [toolbarItem setMaxSize:CGSizeMake(32.0, 32.0)];

    if (anItemIdentifier === PopUpButtonToolbarItemIdentifier)
    {
        [toolbarItem setMinSize:CGSizeMake(120.0, 24.0)];
        [toolbarItem setMaxSize:CGSizeMake(120.0, 24.0)];
    
        var popUpButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 24.0) pullsDown:NO];
        
        [popUpButton addItemWithTitle:@"Option 1"];
        [popUpButton addItemWithTitle:@"Option 2"];
        [popUpButton addItemWithTitle:@"Option 3"];
        
        [toolbarItem setView:popUpButton];
        
        [toolbarItem setTarget:nil];
        [toolbarItem setLabel:@"Pop Up Button"];
    }

    else if (anItemIdentifier === SliderToolbarItemIdentifier)
    {
        [toolbarItem setMinSize:CGSizeMake(120.0, 24.0)];
        [toolbarItem setMaxSize:CGSizeMake(120.0, 24.0)];
    
        var slider = [[CPSlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 24.0) ];
        
        [toolbarItem setView:slider];
        
        [toolbarItem setTarget:nil];
        [toolbarItem setLabel:@"Slider"];
    }
    
    else if (anItemIdentifier === ButtonToolbarItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:@"Resources/Cappuccino.png" size:CGSizeMake(32.0, 32.0)],
            alternateImage = [[CPImage alloc] initWithContentsOfFile:@"Resources/CappuccinoAlternate.png" size:CGSizeMake(32.0, 32.0)];
        
        [toolbarItem setLabel:@"Standard"];
        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:alternateImage];
    }
    
    return toolbarItem;
}

@end
