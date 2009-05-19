//
// AppController.j
// FloorPlan
//
// Created by Francisco Tolmasky on November 13th, 2008.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <Foundation/CPObject.j>

@import "FurnitureView.j"
@import "FloorPlanView.j"


@implementation AppController : CPObject
{
    CPArray             furnitureViews;
    CPCollectionView    furnitureCollectionView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView],
        contentSize = [contentView bounds].size;
    
    // Make the background black.
    [contentView setBackgroundColor:[CPColor blackColor]];
    
    // Create and Center our Container View
    var view = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 700.0, 424.0)];
    [view setCenter:[contentView center]];
    
    [view setBackgroundColor:[CPColor colorWithRed:212.0 / 255.0 green:221.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]];
    
    [view setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    
    [contentView addSubview:view];
    
    // Our floor plan
    var floorPlanView = [[FloorPlanView alloc] initWithFrame:CGRectMake(176.0, 0.0, 525.0, 424.0)];
    
    [view addSubview:floorPlanView];
        
    furnitureViews = 
        [
            [self furnitureViewWithName:"Couch" imagePath:@"Resources/Couch.png" size:CGSizeMake(123.0, 58.0)],
            [self furnitureViewWithName:"Love Seat" imagePath:@"Resources/LoveSeat.png" size:CGSizeMake(90.0, 58.0)],
            [self furnitureViewWithName:"Chair" imagePath:@"Resources/Chair.png" size:CGSizeMake(61.0, 60.0)],
            [self furnitureViewWithName:"Bed" imagePath:@"Resources/Bed.png" size:CGSizeMake(113.0, 133.0)],
            [self furnitureViewWithName:"Coffee Table" imagePath:@"Resources/CoffeeTable.png" size:CGSizeMake(73.0, 79.0)],
            [self furnitureViewWithName:"Dining Table" imagePath:@"Resources/DiningTable.png" size:CGSizeMake(185.0, 121.0)]       
        ]
        
    furnitureCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, 176.0, 400.0)];
    
    [furnitureCollectionView setMinItemSize:CGSizeMake(176.0, 50.0)];
    [furnitureCollectionView setMaxItemSize:CGSizeMake(176.0, 50.0)];
        
    var itemPrototype = [[CPCollectionViewItem alloc] init];
    
    [itemPrototype setView:[[FurnitureItemView alloc] initWithFrame:CGRectMakeZero()]];
    
    [furnitureCollectionView setItemPrototype:itemPrototype];
    
    [furnitureCollectionView setContent:furnitureViews];
    [furnitureCollectionView setDelegate:self];
    
    [view addSubview:furnitureCollectionView];
    
    [theWindow makeKeyAndOrderFront:self];
    
    var undoButton = [[CPButton alloc] initWithFrame:CGRectMake(20.0, 394.0, 60.0, 24.0)],
        redoButton = [[CPButton alloc] initWithFrame:CGRectMake(90.0, 394.0, 60.0, 24.0)];
    
    [undoButton setTitle:"Undo"];
    [undoButton setTarget:[theWindow undoManager]];
    [undoButton setAction:@selector(undo)];
    
    [redoButton setTitle:"Redo"];
    [redoButton setTarget:[theWindow undoManager]];
    [redoButton setAction:@selector(redo)];
    
    [view addSubview:undoButton];
    [view addSubview:redoButton];
}

- (FurnitureView)furnitureViewWithName:(CPString)aName imagePath:(CPString)aPath size:(CGSize)aSize
{
    return [[FurnitureView alloc] initWithName:aName image:[[CPImage alloc] initWithContentsOfFile:aPath size:aSize]];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
    return [CPKeyedArchiver archivedDataWithRootObject:[furnitureViews objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
    return [FurnitureViewDragType];
}

@end

@implementation FurnitureItemView : CPView
{
    CPImageView imageView;
    CPTextField textField;
}

- (void)setRepresentedObject:(id)anObject
{
    if (!imageView)
    {
        imageView = [[CPImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
        
        [imageView setImageScaling:CPScaleProportionally];
    
        [self addSubview:imageView];
    }
    
    if (!textField)
    {
        textField = [[CPTextField alloc] initWithFrame:CGRectMake(50.0, 15.0, 145.0, 20.0)];
        
        [textField setFont:[CPFont boldSystemFontOfSize:12.0]];
        [self addSubview:textField];
    }
    
    [imageView setImage:[anObject image]];
    [textField setStringValue:[anObject name]];
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor blueColor] : nil];
    [textField setTextColor:isSelected ? [CPColor whiteColor] : [CPColor blackColor]];
}

@end
