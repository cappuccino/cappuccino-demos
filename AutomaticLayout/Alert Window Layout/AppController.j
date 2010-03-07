
@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // we create the standard initial window and make it visible
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() 
                                                styleMask:CPBorderlessBridgeWindowMask];
    [theWindow orderFront:self];
    
    // then we create our alert window. in most instances, you could just use the CPAlert class,
    // but this is still a useful demonstration of some of the layout features of Cappuccino
    var alertWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(20.0, 40.0, 400.0, 125.0) 
                                                  styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask];

    // windows can have titles
    [alertWindow setTitle:@"Alert"];
    // and they support minimum and maximum sizes
    [alertWindow setMinSize:CGSizeMake(350.0, 110.0)];
    [alertWindow setMaxSize:CGSizeMake(450.0, 150.0)];

    // the root view of all windows is it's contentView. all other views will be children of this view.
    var contentView = [alertWindow contentView];

    // construct an image view to hold our icon, set its image, and add it to the content view
    var iconView = [[CPImageView alloc] initWithFrame:CGRectMake(20.0, 0.0, 80.0, 80.0)],
        iconPath = [[CPBundle mainBundle] pathForResource:@"cappuccino.png"],
        cappuccinoIcon = [[CPImage alloc] initWithContentsOfFile:iconPath 
                                                            size:CGSizeMake(80.0, 80.0)];

    [iconView setImage:cappuccinoIcon];
    [iconView setImageScaling:CPScaleProportionally];
    [contentView addSubview:iconView];

    // create a text field for our message, and position it and add it to the content view
    var textField = [CPTextField labelWithTitle:@"This is a message to the user."];
    [textField setTextColor:[CPColor whiteColor]];
    [textField setFrameOrigin:CGPointMake(100.0, 10.0)];
    [contentView addSubview:textField];

    // finally, create our buttons and add them to the content view
    var cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(190.0, 85.0, 80.0, 20.0)],
        okButton = [[CPButton alloc] initWithFrame:CGRectMake(285.0, 85.0, 80.0, 20.0)];

    [cancelButton setTitle:@"Cancel"];
    [cancelButton setTheme:[CPTheme themeNamed:@"Aristo-HUD"]];

    [okButton setTitle:@"OK"];
    [okButton setTheme:[CPTheme themeNamed:@"Aristo-HUD"]];

    [contentView addSubview:okButton];
    [contentView addSubview:cancelButton]; 

    // Autoresizing Masks:
    // we want the buttons to stay fixed to the bottom right corner of the window
    [cancelButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
    [okButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

    // display the alert window
    [alertWindow orderFront:self];
}

@end
