
@import <Foundation/CPObject.j>
@import <AppKit/CPImage.j>
@import <AppKit/CALayer.j>

var _imagesLoaded = 0;

@implementation LOTile : CALayer
{
	CPImage _onImage;
	CPImage _offImage;
	
	CPImage _onImagePressed;
	CPImage _offImagePressed;
	
	
	BOOL _on;
	BOOL _pressed;
}

-(BOOL)fullyLoaded
{
    if (_imagesLoaded < 4)
        return NO;
    else
    
    return YES;

}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        _onImage = [[CPImage alloc] initWithContentsOfFile:"Resources/lo-button-on.png" size:CPSizeMake(63, 57)];
        _offImage = [[CPImage alloc] initWithContentsOfFile:"Resources/lo-button-off.png" size:CPSizeMake(63, 57)];
        _onImagePressed = [[CPImage alloc] initWithContentsOfFile:"Resources/lo-button-on-press.png" size:CPSizeMake(63, 57)];
        _offImagePressed = [[CPImage alloc] initWithContentsOfFile:"Resources/lo-button-off-press.png" size:CPSizeMake(63, 57)];
        
        [_onImage setDelegate:self];
        [_offImage setDelegate:self];
        [_onImagePressed setDelegate:self];
        [_offImagePressed setDelegate:self];
    }
    
    return self;
}

-(BOOL)isOn
{
    return _on;
}

-(BOOL)isPressed
{
    return _pressed;
}

-(void)setOn:(BOOL)b
{
    _on = b;
    [self setNeedsDisplay];
}

-(void)setPressed:(BOOL)b
{
    _pressed = b;
    [self setNeedsDisplay];
}

- (void)imageDidLoad:(CPImage)anImage
{
    _imagesLoaded++;

    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContext)aContext
{

    if (_imagesLoaded < 4)
        return;

    var bounds = [self bounds];

        if (_on)
        {
            if (_pressed)
            {
                if ([_onImagePressed loadStatus] === CPImageLoadStatusCompleted)
                    CGContextDrawImage(aContext, bounds, _onImagePressed);
            }
            else
            {
                if ([_onImage loadStatus] === CPImageLoadStatusCompleted)
                    CGContextDrawImage(aContext, bounds, _onImage);
            }
        }
        else
        {
            if (_pressed)
            {
                if ([_offImagePressed loadStatus] === CPImageLoadStatusCompleted)
                   CGContextDrawImage(aContext, bounds, _offImagePressed);
            }
            else
            {
                if ([_offImage loadStatus] === CPImageLoadStatusCompleted)
                    CGContextDrawImage(aContext, bounds, _offImage);
            }
        }
}

@end
