//
// AppController.j
// Puzzle
//
// Created by Ross Boucher.
// Copyright 2005 - 2008, 280 North, Inc. All rights reserved.
//

@import <Foundation/CPObject.j>
@import "PhotoBrowser.j"

var kBoardWidth=4,
    kBoardHeight=4,
    kSpacing=1;

@implementation AppController : CPObject
{
    CPView          _gameView;
    CPImage         _gameImage;
    
    PhotoBrowser    _photoBrowserView;
    
    CPArray         _clipViews;
    CPArray         _originalPositions;
    
    id              _emptySquare;

    CPButton        _reshuffleButton;
    CPButton        _chooseButton;
    CPImage         _shuffleImage;
    CPImage         _stopShuffleImage;

    BOOL            _didWin;
    BOOL            _shuffle;
    BOOL            _isGameView;
    BOOL            _isAnimating;
    int             _lastMove;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    _gameView = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    
    [_gameView setBackgroundColor:[CPColor darkGrayColor]];
    [_gameView enterFullScreenMode:nil withOptions:nil];
    
    [[_gameView window] setFrameSize: CPSizeMake(320, 416)];
    [_gameView setFrameSize:CPSizeMake(640, 416)];

    var bottomImage = [[CPImage alloc] initWithContentsOfFile:"Resources/background.png" size:CPSizeMake(320, 96)];
    var bottom = [[CPImageView alloc] initWithFrame:CPRectMake(0,320+3, 320, 96)];
    
    [bottom setImage:bottomImage];
    [_gameView addSubview:bottom];
    
    _shuffleImage = [[CPImage alloc] initWithContentsOfFile:"Resources/shuffleButton.png" size:CPSizeMake(121, 96)];
    _stopShuffleImage = [[CPImage alloc] initWithContentsOfFile:"Resources/stopButton.png" size:CPSizeMake(121, 96)];
    _reshuffleButton = [[CPButton alloc] initWithFrame:CPRectMake(23, 320+5, 121, 96)];
    
    [_reshuffleButton setBordered:NO];
    [_reshuffleButton setImage:_shuffleImage];
    [_reshuffleButton setTarget:self];
    [_reshuffleButton setAction:@selector(toggleShuffle)];
    
    [_gameView addSubview: _reshuffleButton];
        
    var chooseImage = [[CPImage alloc] initWithContentsOfFile:"Resources/switchButton.png" size:CPSizeMake(121, 96)];
    _chooseButton = [[CPButton alloc] initWithFrame:CPRectMake(176, 320+5, 121, 96)];
  
    [_chooseButton setBordered:NO];
    [_chooseButton setImage:chooseImage];
    [_chooseButton setTarget:self];
    [_chooseButton setAction:@selector(togglePhotoBrowser)];
  
    [_gameView addSubview: _chooseButton];
 
 
    _clipViews = new Array(kBoardWidth*kBoardHeight);
    _originalPositions = new Array(kBoardWidth*kBoardHeight);
        
    for(var i=0; i<_clipViews.length; i++)
    {
        _originalPositions[i] = [[CPButton alloc] initWithFrame:CPRectMake(0,0,320,480)];
        
        [_originalPositions[i] setBordered:NO];
        [_originalPositions[i] setTarget: self];
        [_originalPositions[i] setAction: @selector(onClick:)];
        [_originalPositions[i] registerForClicks];

        _clipViews[i] = [[CPClipView alloc] initWithFrame:CPRectMake((320/kBoardWidth+kSpacing)*(i%kBoardWidth),
                                                                     (FLOOR(320/kBoardHeight)+kSpacing)*(FLOOR(i/kBoardWidth)),
                                                                      320/kBoardWidth,
                                                                      320/kBoardHeight)];
                                                                              
        [_clipViews[i] setDocumentView:_originalPositions[i]];
        [_clipViews[i] scrollToPoint:CPPointMake((320/kBoardWidth)*(i%kBoardWidth), ((320/kBoardHeight)*(FLOOR(i/kBoardWidth)) + 80))];

        [_gameView addSubview: _clipViews[i]];
    }        
    
    [self setImage: [[CPImage alloc] initWithContentsOfFile:"Resources/1.jpg" size:CPSizeMake(320, 480)]];
    
    _emptySquare = _originalPositions[kBoardWidth*kBoardHeight-1];
    [_emptySquare setHidden: YES];

    [self toggleShuffle];

    _isGameView = YES;
    
    _photoBrowserView = [[PhotoBrowser alloc] initWithFrame:CGRectMake(320, 0, 320, 416)];
    [_photoBrowserView setDelegate:self];
    
    [_gameView addSubview: _photoBrowserView];

    //This is just a hack until we develop a better iPhone solution. Ugly, but necessary.
    CPSharedDOMWindowBridge._DOMFocusElement.parentNode.removeChild(CPSharedDOMWindowBridge._DOMFocusElement);    
    //This scrolls the url bar away.
    setTimeout(scrollTo, 100, 0, 1);
}

- (void)setImage:(CPImage)anImage
{
    if (anImage == _gameImage)
        return;
        
    _gameImage = anImage;
            
    for(var i=0, imageSize = [_gameImage size]; i<_clipViews.length; i++)
    {
        [_originalPositions[i] setImage:_gameImage];
        [_originalPositions[i] setFrameSize:CGSizeMakeCopy(imageSize)];
    }
}

- (void)onClick:(id)sender
{
    if(_shuffle)
        return [self toggleShuffle];

    if(sender == _emptySquare)
        return;
        
    var emptySquareIndex = [_clipViews indexOfObject:[_emptySquare superview]],
        index = [_clipViews indexOfObject:[sender superview]],
        x = index%kBoardWidth,
        y = FLOOR(index/kBoardWidth),
        swapSquares = [],
        forSquares = [];    

    for(var pos=x-1, i=1; pos>=0; pos--, i++)
    {
        if([_clipViews[y*kBoardWidth+pos] documentView]==_emptySquare)
        {
            for(; i>0; i--)
            {
                swapSquares.push(y*kBoardWidth+x-i+1);
                forSquares.push(y*kBoardWidth+x-i);
            }
            
            [self swapSquares: swapSquares withSquares: forSquares]; 
            return;
        }
    }

    for(var pos=x+1, i=1; pos<kBoardWidth; pos++, i++)
    {
        if([_clipViews[y*kBoardWidth+pos] documentView]==_emptySquare)
        {
            for(; i>0; i--)
            {
                swapSquares.push(y*kBoardWidth+x+i-1);
                forSquares.push(y*kBoardWidth+x+i);
            }
            
            [self swapSquares: swapSquares withSquares: forSquares]; 
            return;
        }
    }
    
    for(var pos=y-1, i=1; pos>=0; pos--, i++)
    {
        if([_clipViews[pos*kBoardWidth+x] documentView]==_emptySquare)
        {
            for(; i>0; i--)
            {
                swapSquares.push((y-i+1)*kBoardWidth+x);
                forSquares.push((y-i)*kBoardWidth+x);
            }
            
            [self swapSquares: swapSquares withSquares: forSquares]; 
            return;
        }
    }
    
    for(var pos=y+1, i=1; pos<kBoardHeight; pos++, i++)
    {
        if([_clipViews[pos*kBoardWidth+x] documentView]==_emptySquare)
        {
            for(; i>0; i--)
            {
                swapSquares.push((y+i-1)*kBoardWidth+x);
                forSquares.push((y+i)*kBoardWidth+x);
            }
            
            [self swapSquares: swapSquares withSquares: forSquares]; 
            return;
        }
    }
}

- (void)togglePhotoBrowser
{
    if(_isAnimating)
        return;
        
    if(_shuffle) 
        [self toggleShuffle];
    
    var finished = function(){_isAnimating = NO;};
    
    if(_isGameView)
        [CPView animateViews:[_gameView] toRects:[CGRectMake(-320, 0, 640, 416)] duration: 600 callback: finished];
    else 
        [CPView animateViews:[_gameView] toRects:[CGRectMake(0, 0, 640, 416)] duration: 600 callback: finished];
    
    _isAnimating = YES;
    
    _isGameView = !_isGameView;
}

- (void)toggleShuffle
{
    if(_shuffle)
    {
        _shuffle = NO;
        [_reshuffleButton setImage:_shuffleImage];
    }
    else
    {
        _didWin = NO;
        _shuffle = YES;        

        [_reshuffleButton setImage:_stopShuffleImage];
        [self shuffleSquares];
    }
}

- (void)photoBrowser:(PhotoBrowser)aPhotoBrowser didEnd:(unsigned)aReturnValue
{
    if (aReturnValue == CPCancelButton)
        return [self togglePhotoBrowser];
    
    var selectedImage = [aPhotoBrowser selectedImage];
    
    if(selectedImage.url == [_gameImage filename])
        return [self togglePhotoBrowser];

    [self setImage: [[CPImage alloc] initWithContentsOfFile: selectedImage.url size: CPSizeMake(320, 480)]];
    
    [self togglePhotoBrowser];
}

- (void)swapSquares:(CPArray)array1 withSquares:(CPArray)array2
{
    var views = new Array(array1.length),
        rects = new Array(array1.length);
        
    for(var i=0, count = [array1 count]; i<count; i++)
    {
        var frame2 = [_clipViews[array2[i]] frame],
            frame1 = [_clipViews[array1[i]] frame];
            
        views[i] = _clipViews[array1[i]];
        rects[i] = CGRectCreateCopy(frame2);
        
        [_clipViews[array2[i]] setFrame:frame1];
            
        var emptyClipView = _clipViews[array2[i]];
        _clipViews[array2[i]] = _clipViews[array1[i]];
        _clipViews[array1[i]] = emptyClipView;
    }
    
    [CPView animateViews:views toRects:rects duration: 100 callback: function()
    {
        //the brackets are necessary because of a bug in the parser
        if (_shuffle) 
        {
            [self shuffleSquares];
        }
        else
        {
            [self checkWin];
        }
    }];
}

- (void)shuffleSquares
{
    if(!_shuffle)
        return;

    var availableMoves = [],
        emptySquareIndex = [_clipViews indexOfObject:[_emptySquare superview]],
        x = emptySquareIndex%kBoardWidth,
        y = FLOOR(emptySquareIndex/kBoardWidth);
                
    if (x>0 && _lastMove != emptySquareIndex-1) 
        availableMoves.push(emptySquareIndex-1);
    if (x<kBoardWidth-1 && _lastMove != emptySquareIndex+1) 
        availableMoves.push(emptySquareIndex+1);
    if (y>0 && _lastMove != emptySquareIndex-kBoardWidth) 
        availableMoves.push(emptySquareIndex-kBoardWidth);
    if (y<kBoardHeight-1 && _lastMove != emptySquareIndex+kBoardWidth) 
        availableMoves.push(emptySquareIndex+kBoardWidth);

    var move = availableMoves[FLOOR(Math.random()*availableMoves.length)];
    _lastMove = emptySquareIndex;
    
    [self swapSquares:[move] withSquares:[emptySquareIndex]];
}

- (void)checkWin
{
    if (_didWin) 
        return;
        
    for (var i=0; i<_clipViews.length; i++)
        if ([_clipViews[i] documentView]!=_originalPositions[i])
            return;

    _didWin=YES;
    
    alert("Congratulations!");
}

@end


//CPView category to add a simple animation method

@implementation CPView (Animation)

+ (void)animateViews:(CPArray)views toRects:(CPArray)rects duration:(int)millis callback:(Function)aFunction
{
    var startTime = new Date().getTime(),
        startRects = [CPArray array];

    for (var i=0; i<views.length; i++)
        startRects[i]=[views[i] frame];
    
    var animationFunction = function()
    {
        var i = views.length,
            finished =YES;
        
        while (i--)
        {
            var startX = CPRectGetMinX(startRects[i]),
                startY = CPRectGetMinY(startRects[i]),
                aRectX = CPRectGetMinX(rects[i]),
                aRectY = CPRectGetMinY(rects[i]),
                newX, newY;
                
            var currentTime = new Date().getTime(),
                percent = (MIN((currentTime-startTime), millis) / millis );
                    
            newX=startX+(percent)*(aRectX-startX);
            newY=startY+(percent)*(aRectY-startY);
                                
            startRects[i].origin =  CPPointMake(newX, newY);
                        
            [views[i] setFrameOrigin: startRects[i].origin];

            if (!CPPointEqualToPoint(startRects[i].origin, rects[i].origin)) 
                finished = NO;       
        }

        if (!finished) 
            window.setTimeout(animationFunction, 50);
        else
        {
            var i = views.length;
            
            while (i--) 
                [views[i] setFrame:rects[i]];
            
            if (aFunction)
                aFunction();
        }
    }

    setTimeout(animationFunction, 0);
}

@end

@implementation CPControl (iPhone)

-(void)registerForClicks
{
    var func = function(){};
    
    _DOMElement.addEventListener("click", func, false);
    _DOMElement.removeEventListener("click", func, false);
}

@end
