
@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];

    [theWindow orderFront:self];
    
    var alertWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(10.0, 10.0, 400.0, 160.0) styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask];

    [alertWindow setTitle:@"Alert"];

    contentView = [alertWindow contentView];

    var iconView = [[CPImageView alloc] initWithFrame:CGRectMake(20.0, 0.0, 80.0, 80.0)];

    [iconView setImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"cappuccino.png"] size:CGSizeMake(80.0, 80.0)]];
    [iconView setImageScaling:CPScaleProportionally];
    
    [contentView addSubview:iconView];
    
    // Autoresizing Mask
    [iconView setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
    
    var textField = [[CPTextField alloc] initWithFrame:CGRectMake(103.0, 10.0, 240.0, 95.0)];
    
    [textField setTextColor:[CPColor whiteColor]];
    [textField setStringValue:@"This is a message to the user."];
    
    // Autoresizing Mask
    [textField setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    
    [contentView addSubview:textField];
    
    var cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(190.0, 85.0, 80.0, 20.0)],
        okButton = [[CPButton alloc] initWithFrame:CGRectMake(285.0, 85.0, 80.0, 20.0)];

    [cancelButton setTitle:@"Cancel"];
    [cancelButton setBezelStyle:CPHUDBezelStyle];

    // Autoresizing Mask
    [cancelButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

    [contentView addSubview:cancelButton]; 

    [okButton setTitle:@"OK"];
    [okButton setBezelStyle:CPHUDBezelStyle];

    // Autoresizing Mask
    [okButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

    [contentView addSubview:okButton];

    [alertWindow orderFront:self];
}

@end
