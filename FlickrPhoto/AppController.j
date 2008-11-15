//
// AppController.j
// FlickrPhoto
//
// Created by Ross Boucher.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <Foundation/CPObject.j>
@import <Foundation/CPURLRequest.j>
@import <Foundation/CPJSONPConnection.j>

@import <AppKit/CPSlider.j>
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>
@import <AppKit/CPCollectionView.j>


var SliderToolbarItemIdentifier = "SliderToolbarItemIdentifier",
    AddToolbarItemIdentifier = "AddToolbarItemIdentifier",
    RemoveToolbarItemIdentifier = "RemoveToolbarItemIdentifier";

/*
    Important note about CPJSONPConnection: CPJSONPConnection is <strong>only</strong> for JSONP APIs.
    If aren't sure you <strong>need</strong>
    <a href="http://ajaxian.com/archives/jsonp-json-with-padding">JSON<strong>P</strong></a>,
    you most likely don't want to use CPJSONPConnection, but rather the more standard
    <objj>CPURLConnection</objj>. CPJSONPConnection is designed for cross-domain
    connections, and if you are making requests to the same domain (as most web
    applications do), you do not need it.
*/

@implementation AppController : CPObject
{
    CPURLConnection         tagConnection;
    CPString                lastIdentifier;
    
    CPDictionary            photosets;
    
    CPWindow                theWindow;
    
    CPCollectionView        listCollectionView;
    CPCollectionView        photosCollectionView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogPopup);
    photosets = [CPDictionary dictionary];
    
    theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    
    var contentView = [theWindow contentView],
        toolbar = [[CPToolbar alloc] initWithIdentifier:"Photos"];
    
    [toolbar setDelegate:self];
	[toolbar setVisible:true];

	[theWindow setToolbar:toolbar];

    var bounds = [contentView bounds];

    var listScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds))];
    [listScrollView setAutohidesScrollers: YES];
        
    var photosListItem = [[CPCollectionViewItem alloc] init];
    [photosListItem setView: [[PhotosListCell alloc] initWithFrame:CGRectMakeZero()]];

    listCollectionView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds))];

    [listCollectionView setDelegate: self];
    [listCollectionView setItemPrototype: photosListItem];
    
    [listCollectionView setMinItemSize:CGSizeMake(20.0, 55.0)];
    [listCollectionView setMaxItemSize:CGSizeMake(1000.0, 55.0)];
    [listCollectionView setMaxNumberOfColumns:1];
    
    [listCollectionView setVerticalMargin:0.0];
    [listCollectionView setAutoresizingMask: CPViewWidthSizable];

    [listScrollView setDocumentView: listCollectionView];        
    [[listScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

    [contentView addSubview: listScrollView];    

    //border
    var borderView = [[CPView alloc] initWithFrame:CGRectMake(199, 0, 1, CGRectGetHeight(bounds))];
    
    [borderView setBackgroundColor: [CPColor blackColor]];
    [borderView setAutoresizingMask: CPViewHeightSizable];
    
    [contentView addSubview: borderView];

    var photoItem = [[CPCollectionViewItem alloc] init];
    [photoItem setView: [[PhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(200, 0, CGRectGetWidth(bounds) - 200, CGRectGetHeight(bounds))];

    photosCollectionView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(bounds) - 200, 0)];

    [photosCollectionView setDelegate: self];
    [photosCollectionView setItemPrototype: photoItem];
    
    [photosCollectionView setMinItemSize:CGSizeMake(150, 150)];
    [photosCollectionView setMaxItemSize:CGSizeMake(150, 150)];
    [photosCollectionView setAutoresizingMask: CPViewWidthSizable];
    
    [scrollView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [scrollView setDocumentView: photosCollectionView];
    [scrollView setAutohidesScrollers: YES];

    [[scrollView contentView] setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 alpha:1.0]];
    
    [contentView addSubview: scrollView];    


    //bring forward the window
    
    [theWindow orderFront:self];


    //get the most interesting photos on flickr
    
    var request = [CPURLRequest requestWithURL:"http://www.flickr.com/services/rest/?method=flickr.interestingness.getList&per_page=20&format=json&api_key=ca4dd89d3dfaeaf075144c3fdec76756"];
    
    // see important note about CPJSONPConnection above
    var connection = [CPJSONPConnection sendRequest: request callback: "jsoncallback" delegate: self];
    
    lastIdentifier = "Interesting Photos";
}

- (void)add:(id)sender
{
    var string = prompt("Enter a tag to search Flickr for photos.");

    if(string)
    {
        var request = [CPURLRequest requestWithURL:"http://www.flickr.com/services/rest/?"+
                                                    "method=flickr.photos.search&tags="+encodeURIComponent(string)+
                                                    "&media=photos&machine_tag_mode=any&per_page=20&format=json&api_key=ca4dd89d3dfaeaf075144c3fdec76756"];
    
        // see important note about CPJSONPConnection above
        tagConnection = [CPJSONPConnection sendRequest: request callback: "jsoncallback" delegate: self];
        
        lastIdentifier = string;
    }
}

- (void)remove:(id)sender
{
    [self removeImageListWithIdentifier: [[photosets allKeys] objectAtIndex:[[listCollectionView selectionIndexes] firstIndex]]];
}

- (void)addImageList:(CPArray)images withIdentifier:(CPString)aString
{
    [photosets setObject:images forKey:aString];
    
    [listCollectionView setContent: [[photosets allKeys] copy]];
    [listCollectionView setSelectionIndexes: [CPIndexSet indexSetWithIndex: [[photosets allKeys] indexOfObject: aString]]];
}

- (void)removeImageListWithIdentifier:(CPString)aString
{
    var nextIndex = MAX([[listCollectionView content] indexOfObject: aString] - 1, 0);
    
    [photosets removeObjectForKey:aString];

    [listCollectionView setContent: [[photosets allKeys] copy]];
    [listCollectionView setSelectionIndexes: [CPIndexSet indexSetWithIndex: nextIndex]];    
}

- (void)adjustImageSize:(id)sender
{
    var newSize = [sender value];
    
    [photosCollectionView setMinItemSize:CGSizeMake(newSize, newSize)];
    [photosCollectionView setMaxItemSize:CGSizeMake(newSize, newSize)];
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
    if (aCollectionView == listCollectionView)
    {
        var listIndex = [[listCollectionView selectionIndexes] firstIndex],
            key = [listCollectionView content][listIndex];
            
        [photosCollectionView setContent: [photosets objectForKey:key]];
        [photosCollectionView setSelectionIndexes: [CPIndexSet indexSet]];
    }
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
    [self addImageList: data.photos.photo withIdentifier: lastIdentifier];
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
    alert(error);
}

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [CPToolbarFlexibleSpaceItemIdentifier, SliderToolbarItemIdentifier, AddToolbarItemIdentifier, RemoveToolbarItemIdentifier];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [AddToolbarItemIdentifier, RemoveToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, SliderToolbarItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];

    if (anItemIdentifier == SliderToolbarItemIdentifier)
    {
        [toolbarItem setView: [[PhotoResizeView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)]];
        [toolbarItem setMinSize:CGSizeMake(180, 50)];
        [toolbarItem setMaxSize:CGSizeMake(180, 50)];
    }
    else if (anItemIdentifier == AddToolbarItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/add.png" size:CPSizeMake(30, 25)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/addHighlighted.png" size:CPSizeMake(30, 25)];
            
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlighted];
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(add:)];
        [toolbarItem setLabel: "Add Photo List"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if (anItemIdentifier == RemoveToolbarItemIdentifier)
    {        
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/remove.png" size:CPSizeMake(30, 25)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/removeHighlighted.png" size:CPSizeMake(30, 25)];
            
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlighted];

        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(remove:)];
        [toolbarItem setLabel: "Remove Photo List"];
        
        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    
    return toolbarItem;
}

@end

@implementation PhotoResizeView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    var slider = [[CPSlider alloc] initWithFrame: CGRectMake(38, CGRectGetHeight(aFrame)/2.0 - 8, CGRectGetWidth(aFrame) - 80, 16)];

    [slider setMinValue: 50.0];
    [slider setMaxValue: 250.0];
    [slider setTarget: self];
    [slider setAction: @selector(sliderChangedValue:)];
    
    [self addSubview: slider];

    [slider setValue: 150.0];
                                                             
    var label = [[CPTextField alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(aFrame)/2.0 - 12, 40, 16)];
    
    [label setAlignment: CPCenterTextAlignment];
    [label setFont: [CPFont systemFontOfSize: 12.0]];
    [label setStringValue: "50"];
    
    [self addSubview: label];

    label = [[CPTextField alloc] initWithFrame: CGRectMake(CGRectGetWidth(aFrame) - 40, CGRectGetHeight(aFrame)/2.0 - 12, 40, 16)];
    
    [label setAlignment: CPCenterTextAlignment];
    [label setFont: [CPFont systemFontOfSize: 12.0]];
    [label setStringValue: "250"];
    
    [self addSubview: label];
    
    return self;
}

- (void)sliderChangedValue:(id)sender
{
    [CPApp sendAction:@selector(adjustImageSize:) to: nil from: sender];
}

@end


@implementation PhotosListCell : CPView
{
    CPTextField     label;
    CPView          highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    if(!label)
    {
        label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
        [label setFont: [CPFont systemFontOfSize: 16.0]];
        [label setTextColor: [CPColor blackColor]];
        
        [self addSubview: label];
    }

    [label setStringValue: anObject];
    [label sizeToFit];

    [label setFrameOrigin: CGPointMake(10,CGRectGetHeight([label bounds]) / 2.0)];
}

- (void)setSelected:(BOOL)flag
{
    if(!highlightView)
    {
        highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [highlightView setBackgroundColor: [CPColor blueColor]];
    }

    if(flag)
    {
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo: label];
        [label setTextColor: [CPColor whiteColor]];    
    }
    else
    {
        [highlightView removeFromSuperview];
        [label setTextColor: [CPColor blackColor]];
    }
}

@end

@implementation PhotoCell : CPView
{
    CPImage         image;
    CPImageView     imageView;
    CPView          highlightView;
    
    JSObject        imageInfo;
}

- (void)setRepresentedObject:(JSObject)anObject
{
    if(!imageView)
    {
        imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([self bounds])];
        [imageView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
        [imageView setImageScaling: CPScaleProportionally];
        [imageView setHasShadow:YES];
        [self addSubview: imageView];
    }
    
    imageInfo = anObject;
    
    [image setDelegate: nil];
    
    image = [[CPImage alloc] initWithContentsOfFile: thumbForFlickrPhoto(anObject)];

    [image setDelegate: self];
    
    if([image loadStatus] == CPImageLoadStatusCompleted)
        [imageView setImage: image];
    else
        [imageView setImage: nil];
}

- (void)imageDidLoad:(CPImage)anImage
{
    [imageView setImage: anImage];
}

- (void)setSelected:(BOOL)flag
{
    if(!highlightView)
    {
        highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [highlightView setBackgroundColor: [CPColor colorWithCalibratedWhite: 0.8 alpha: 0.6]];
    }

    if(flag)
    {
        [highlightView setFrame:CGRectInset([imageView imageRect], -10.0, -10.0)];
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo: imageView];
    }
    else
        [highlightView removeFromSuperview];
}

@end

function urlForFlickrPhoto(photo)
{
    return "http://farm"+photo.farm+".static.flickr.com/"+photo.server+"/"+photo.id+"_"+photo.secret+".jpg";
}

function thumbForFlickrPhoto(photo)
{
    return "http://farm"+photo.farm+".static.flickr.com/"+photo.server+"/"+photo.id+"_"+photo.secret+"_m.jpg";
}
