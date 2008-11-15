//
// EditorView.j
// FloorPlan
//
// Created by Francisco Tolmasky on November 13th, 2008.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <AppKit/CPView.j>


var SharedEditorView            = nil,
    SharedEditorHandleRadius    = 5.0;

@implementation EditorView : CPView
{
    BOOL            isRotating;
    float           rotationRadians;
    
    FurnitureView   furnitureView;
}

+ (id)sharedEditorView
{
    if (!SharedEditorView)
        SharedEditorView = [[EditorView alloc] initWithFrame:CGRectMakeZero()];
    
    return SharedEditorView;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self)
        rotationRadians = 0;
    
    return self;
}

- (void)setFurnitureView:(FurnitureView)aFurnitureView
{
    if (furnitureView == aFurnitureView)
        return;

    var defaultCenter = [CPNotificationCenter defaultCenter];

    if (furnitureView)
    {
        [defaultCenter
            removeObserver:self
                      name:CPViewFrameDidChangeNotification
                    object:furnitureView];
    }
    
    furnitureView = aFurnitureView;
    
    if (furnitureView)
    {
        rotationRadians = [furnitureView rotationRadians];
        
        [defaultCenter
                addObserver:self
               selector:@selector(furnitureViewFrameChanged:)
                   name:CPViewFrameDidChangeNotification 
                 object:furnitureView];
        
        var frame = [aFurnitureView frame],
            imageSize = [[furnitureView image] size],
            length = SQRT(imageSize.width * imageSize.width + imageSize.height * imageSize.height) + 20.0;
        
        [self setFrame:CGRectMake(CGRectGetMidX(frame) - length / 2, CGRectGetMidY(frame) - length / 2, length, length)];
    
        [[furnitureView superview] addSubview:self];
        [[furnitureView superview] addSubview:furnitureView];
    }
    
    else
        [self removeFromSuperview];
}

- (FurnitureView)furnitureView
{
    return furnitureView;
}

- (float)rotationRadians
{
    return rotationRadians;
}

- (void)updateFromFurnitureView
{
    rotationRadians = [furnitureView rotationRadians];
    
    [self setNeedsDisplay:YES];
}

- (void)furnitureViewFrameChanged:(CPView)aView
{
    var frame = [furnitureView frame],
        length = CGRectGetWidth([self frame]);

    [self setFrameOrigin:CGPointMake(CGRectGetMidX(frame) - length / 2, CGRectGetMidY(frame) - length / 2)];
}

- (void)mouseDown:(CPEvent)anEvent
{
    var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        radius = CGRectGetWidth([self frame]) / 2;
    
    location.x -= radius;
    location.y -= radius;
    
    var distance = SQRT(location.x * location.x + location.y * location.y);
    
    if ((distance < radius + 5) && (distance > radius - 9))
    {
        isRotating = YES;
        
        [furnitureView willBeginLiveRotation];
        
        rotationRadians = ATAN2(location.y, location.x);
        
        [self setNeedsDisplay:YES];
    }
    
    else
        [super mouseDown:anEvent];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    if (!isRotating)
        return;
        
    var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        radius = CGRectGetWidth([self frame]) / 2;
        
    rotationRadians = ATAN2(location.y - radius, location.x - radius);

    [furnitureView setRotationRadians:rotationRadians];

    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    if (!isRotating)
        return;
    
    isRotating = NO;
    
    [furnitureView didEndLiveRotation];
}

- (void)drawRect:(CGRect)aRect
{
    var bounds = CGRectInset([self bounds], 5.0, 5.0),
        context = [[CPGraphicsContext currentContext] graphicsPort],
        radius = CGRectGetWidth(bounds) / 2.0;
    
    CGContextSetStrokeColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeEllipseInRect(context, bounds);

    CGContextSetAlpha(context, 0.5);
    CGContextSetFillColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
    CGContextFillEllipseInRect(context, bounds);
        
    CGContextSetAlpha(context, 1.0);
    CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMidX(bounds) + COS(rotationRadians) * radius - SharedEditorHandleRadius, CGRectGetMidY(bounds) + SIN(rotationRadians) * radius - SharedEditorHandleRadius, SharedEditorHandleRadius * 2.0, SharedEditorHandleRadius * 2.0));
}

@end
