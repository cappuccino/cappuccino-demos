//
// FloorPlanView.j
// FloorPlan
//
// Created by Francisco Tolmasky on November 13th, 2008.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <AppKit/CPView.j>

@import "EditorView.j"


@implementation FloorPlanView : CPImageView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self)
    {
        [self setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/FloorPlan.png" size:CGSizeMake(525.0, 424.0)]];
    
        // Register for "furniture" drag and drop
        [self registerForDraggedTypes:[FurnitureViewDragType]];
    }
    
    return self;
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[EditorView sharedEditorView] setFurnitureView:nil];
}

- (void)addFurnitureView:(FurnitureView)aFurnitureView
{
    [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(removeFurnitureView:) object:aFurnitureView];

    [self addSubview:aFurnitureView];
    
    [[EditorView sharedEditorView] setFurnitureView:aFurnitureView];
}

- (void)removeFurnitureView:(FurnitureView)aFurnitureView
{
    [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(addFurnitureView:) object:aFurnitureView];

    [self addSubview:aFurnitureView];
    
    var editorView = [EditorView sharedEditorView];
    
    if ([editorView furnitureView] == aFurnitureView)
        [editorView setFurnitureView:nil];
        
    [aFurnitureView removeFromSuperview];
}

// Received a furniture "drop"...
- (void)performDragOperation:(CPDraggingInfo)aSender
{
    var furnitureView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:FurnitureViewDragType]],
        location = [self convertPoint:[aSender draggingLocation] fromView:nil];
    
    [furnitureView setFrameOrigin:CGPointMake(location.x - CGRectGetWidth([furnitureView frame]) / 2.0, location.y - CGRectGetHeight([furnitureView frame]) / 2.0)];
    
    [self addFurnitureView:furnitureView];
}

@end
