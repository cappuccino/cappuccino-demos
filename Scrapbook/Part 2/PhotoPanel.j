
@import <AppKit/CPPanel.j>


PhotoDragType = "PhotoDragType";

@implementation PhotoPanel : CPPanel
{
    CPArray images;
}

- (id)init
{
    self = [self initWithContentRect:CGRectMake(50.0, 50.0, 250.0, 360.0) styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask];

    if (self)
    {
        [self setTitle:@"Photos"];
        [self setFloatingPanel:YES];
        
        var contentView = [self contentView],
            bounds = [contentView bounds];
        
        bounds.size.height -= 20.0;
        
        var photosView = [[CPCollectionView alloc] initWithFrame:bounds];
        
        [photosView setAutoresizingMask:CPViewWidthSizable];
        [photosView setMinItemSize:CGSizeMake(100, 100)];
        [photosView setMaxItemSize:CGSizeMake(100, 100)];
        [photosView setDelegate:self];
        
        var itemPrototype = [[CPCollectionViewItem alloc] init];
        
        [itemPrototype setView:[[PhotoView alloc] initWithFrame:CGRectMakeZero()]];
        
        [photosView setItemPrototype:itemPrototype];
        
        var scrollView = [[CPScrollView alloc] initWithFrame:bounds];
        
        [scrollView setDocumentView:photosView];
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [scrollView setAutohidesScrollers:YES];

        [[scrollView contentView] setBackgroundColor:[CPColor whiteColor]];

        [contentView addSubview:scrollView];
        
        images = [ [[CPImage alloc] initWithContentsOfFile:@"Resources/sample.jpg"
                                                      size:CGSizeMake(500.0, 430.0)], 
                    [[CPImage alloc] initWithContentsOfFile:@"Resources/sample2.jpg"
                                                       size:CGSizeMake(500.0, 389.0)],
                    [[CPImage alloc] initWithContentsOfFile:@"Resources/sample3.jpg"
                                                       size:CGSizeMake(413.0, 400.0)],
                    [[CPImage alloc] initWithContentsOfFile:@"Resources/sample4.jpg"
                                                       size:CGSizeMake(500.0, 375.0)],
                    [[CPImage alloc] initWithContentsOfFile:@"Resources/sample5.jpg"
                                                       size:CGSizeMake(500.0, 375.0)],
                    [[CPImage alloc] initWithContentsOfFile:@"Resources/sample6.jpg"
                                                       size:CGSizeMake(500.0, 375.0)] ];
                    
        [photosView setContent:images];
    }

    return self;
}


- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
    return [CPKeyedArchiver archivedDataWithRootObject:[images objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
    return [PhotoDragType];
}

@end

@implementation PhotoView : CPImageView
{
    CPImageView _imageView;
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

- (void)setRepresentedObject:(id)anObject
{
    if (!_imageView)
    {
        _imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 5.0, 5.0)];
        
        [_imageView setImageScaling:CPScaleProportionally];
        [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        
        [self addSubview:_imageView];
    }
    
    [_imageView setImage:anObject];
}

@end
