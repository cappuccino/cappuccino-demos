//
// PhotoBrowser.j
// Puzzle
//
// Created by Ross Boucher.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <AppKit/CPView.j>
@import <AppKit/CPPanel.j>
@import <AppKit/CPCollectionView.j>

@implementation PhotoBrowser : CPView
{
    CPArray             _images;
    CPCollectionView    _imagesCollectionView;
    
    CPButton            _okay;
    CPButton            _cancel;
    
    id                  _delegate;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
                
    [self setBackgroundColor: [CPColor whiteColor]];
    
    var imageItem = [[CPCollectionViewItem alloc] init];
    [imageItem setView:[[ImageCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 83.0, 83.0)]];

    _imagesCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(aRect), 416.0)];
    
    [_imagesCollectionView setItemPrototype:imageItem];
    [_imagesCollectionView setMinItemSize:CGSizeMake(83.0, 83.0)];
    [_imagesCollectionView setMaxItemSize:CGSizeMake(83.0, 83.0)];
    [_imagesCollectionView setMaxNumberOfColumns: 3];
    [_imagesCollectionView setVerticalMargin: 10.0];
        
    for(var i=1, _images = []; i<7; i++)
    {
        _images.push({
            url: "Resources/"+i+".jpg",
            thumb: "Resources/"+i+".thumbnail.jpg"
        });
    }
    
    [_imagesCollectionView setContent: _images];
    [_imagesCollectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex: 0]];
    
    [self addSubview: _imagesCollectionView];
    
    var bottom = [[CPImageView alloc] initWithFrame:CPRectMake(0,324, 320, 96)];    
    [bottom setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/background.png" size:CPSizeMake(320, 96)]];
    
    [self addSubview:bottom];
    
    _okay = [[CPButton alloc] initWithFrame:CPRectMake(176, 326, 121, 96)];    
    [_okay setImage:[[CPImage alloc] initWithContentsOfFile:"Resources/okayButton.png" size:CPSizeMake(121, 96)]];
    
    [_okay setBordered:NO];
    [_okay setTarget:self];
    [_okay setAction:@selector(ok:)];
    [_okay registerForClicks];

    [self addSubview: _okay];

    _cancel = [[CPButton alloc] initWithFrame:CPRectMake(23, 326, 121, 96)];    
    [_cancel setImage: [[CPImage alloc] initWithContentsOfFile:"Resources/cancelButton.png" size:CPSizeMake(121, 96)]];
    
    [_cancel setBordered:NO];
    [_cancel setTarget:self];
    [_cancel setAction:@selector(cancel:)];
    [_cancel registerForClicks];

    [self addSubview: _cancel];
        
    return self;
}

- (void)ok:(id)sender
{
    [_delegate photoBrowser:self didEnd:CPOKButton];
}

- (void)cancel:(id)sender
{
    [_delegate photoBrowser:self didEnd:CPCancelButton];
}

- (JSObject)selectedImage
{
    return [[_imagesCollectionView items][[[_imagesCollectionView selectionIndexes] firstIndex]] representedObject];
}

- (void)setDelegate:(id)anObject
{
    _delegate = anObject;
}

- (id)delegate
{
    return _delegate;
}

@end

@implementation ImageCell : CPView
{
    CPImageView _imageView;
    CPView      _highlightView;
    
    JSObject    _imageInfo;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    if(!_imageView)
    {
        _imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        [_imageView registerForClicks];
        [self addSubview: _imageView];
    }
    
    _imageInfo = anObject;
    
    [_imageView setImage: [[CPImage alloc] initWithContentsOfFile: _imageInfo.thumb size: CPSizeMake(75, 75)]];
}

- (void)setSelected:(BOOL)flag
{
    if(!_highlightView)
    {
        _highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [_highlightView setBackgroundColor: [CPColor blueColor]];
    }

    if(flag)
        [self addSubview:_highlightView positioned:CPWindowBelow relativeTo: _imageView];
    else
        [_highlightView removeFromSuperview];
}
 
@end
