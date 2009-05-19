
import <Foundation/CPObject.j>
import <AppKit/CPImageView.j>
import <AppKit/CPImage.j>
import <AppKit/CALayer.j>
import "LOTile.j"

var _buttonArray;
var _levelArray;


var ROW_COUNT = 5;
var COLUMN_COUNT = 5;

var kTileWidth = 63;
var kTileHeight = 57;
	
function animateOnLight(index)
{
	[[_buttonArray objectAtIndex:index] setOn:YES];
    [[CPRunLoop currentRunLoop] performSelectors];
	setTimeout(animateOffLight, 50, index);
}

function animateOnLight_NoAuto(index)
{
	[[_buttonArray objectAtIndex:index] setOn:YES];
    [[CPRunLoop currentRunLoop] performSelectors]
}

function animateOffLight(index)
{
	[[_buttonArray objectAtIndex:index] setOn:NO];
    [[CPRunLoop currentRunLoop] performSelectors];	
}

function turnOnLight(index)
{
    [[_buttonArray objectAtIndex:index] setOn:YES];
}

function _loadLevelData()
{
	var i = 0;
	
	var x, y;
	y = 0;
	x = 0;
	
	if (!_levelArray)
	{
        _levelArray = [CPMutableArray array];
        [_levelArray addObject: @"-x---xxx---x-x---xxx---x-"];
        [_levelArray addObject: @"xx-xxx---x-----x---xxx-xx"];
        [_levelArray addObject: @"--x----x--xx-xx--x----x--"];
        [_levelArray addObject: @"x-----x-----x-----x-----x"];
        [_levelArray addObject: @"xxxxxxxxxx-----xxxxxxxxxx"];
    }
                
    var rand_no = Math.floor(5*Math.random())                

    var levelData = [_levelArray objectAtIndex:rand_no];

	while (y<ROW_COUNT) 
	{			  
		while (x<COLUMN_COUNT)
		{					
			var t = [levelData characterAtIndex:(5*(y))+x];
			
			if (t == @"x")
				[[_buttonArray objectAtIndex:(5*(y))+x] setOn:YES];
            else
                [[_buttonArray objectAtIndex:(5*(y))+x] setOn:NO];
			
			x++;
		}
		x = 0;
		y++;
	}	
    [[CPRunLoop currentRunLoop] performSelectors]
}

@implementation LOBoard : CPImageView
{
	BOOL _tilesInit;
	CALayer _rootLayer;
}

/* Mouse events */

-(void)mouseDragged:(CPEvent)event
{
    var point = [event locationInWindow];
        point.y -= 26; /* FIXME: Hacky hack hack */

    var tile = [_rootLayer hitTest:point];
    
    if ([_buttonArray containsObject:tile])
   { 
     for (var i = 0; i < 25; i++)
        {
        var _cur = [_buttonArray objectAtIndex:i];
        
        if (_cur != tile)
         [_cur setPressed:NO];

        }
        [tile setPressed:YES]; 
    }
}

-(void)mouseDown:(CPEvent)event
{

    var point = [event locationInWindow];
        point.y -= 26; /* FIXME: Hacky hack hack */

    var tile = [_rootLayer hitTest:point];
    
    if ([_buttonArray containsObject:tile])
   { 
        for (var i = 0; i < 25; i++)
        {
        var _cur = [_buttonArray objectAtIndex:i];
        
        if (_cur != tile)
         [_cur setPressed:NO];

        }
        [tile setPressed:YES]; 
    }
}

-(void)mouseUp:(CPEvent)event
{
    var point = [event locationInWindow];
        point.y -= 26; /* FIXME: Hacky hack hack */

    var tappedTile = [_rootLayer hitTest:point];
    
    if ([_buttonArray containsObject:tappedTile])
    { 
        [tappedTile setPressed:NO];
     
        var theSelection = [self tilesAdjacentTo: tappedTile];
        
        for (var i = 0; i < [theSelection count]; i++)
        {
            var _cur = [theSelection objectAtIndex:i];
        
            [_cur setOn:![_cur isOn]];
        }
    }
    
    var _goToNextLevel = YES;
    
    for (var i = 0; i < 25; i++)
    {
        var _cur = [_buttonArray objectAtIndex:i];
        if ([_cur isOn])
            _goToNextLevel = NO;
    }
    
    if (_goToNextLevel)
    {
        var totalTime = [self _animateWinSequence];
        setTimeout(_loadLevelData, totalTime*1050);

    }
}

/* Display / Init */

- (void) resetBoard
{
	var a = 0;
	var b = 0;
	
	if (!_tilesInit)
    {
		_rootLayer = [CALayer layer];
            
        [self setWantsLayer:YES];
        [self setLayer:_rootLayer]; 
    
		_buttonArray = [CPMutableArray array];
		
		while (b < 5) 
		{
			while (a < 5)
			{
				var bounds = CGRectMake(0,0, kTileWidth, kTileHeight);
				var location = CGPointMake(32+2+a * kTileWidth, 28+(76+b*7)+b * kTileHeight);
				
				var tile = [[LOTile alloc] init];
				[tile setBounds:bounds];
				[tile setPosition:location];

				[_buttonArray addObject:tile];
				
				[_rootLayer addSublayer:tile];
				[tile setNeedsDisplay];

				a++;
			}
			a = 0;
			b++;
		}
		_tilesInit = YES;
	}

	var totalTime;
	totalTime = [self _showLightFlourish];
	setTimeout(_loadLevelData, totalTime*1050);
}


/* Game Logic */
- (CPArray) tilesAdjacentTo:(LOTile)tile
{
  if (!tile)
    return nil;

    var tileFrame = [tile frame];
    var centerOfTile = CGPointMake(CGRectGetMidX(tileFrame), CGRectGetMidY(tileFrame));

    var neighbors = new Array(4);
    neighbors[0] = CGPointMake(kTileWidth, 0); // left
    neighbors[1] = CGPointMake(-kTileWidth, 0); // right
    neighbors[2] = CGPointMake(0, -kTileHeight); // above
    neighbors[3] = CGPointMake(0, kTileHeight*2); // below

    var i;
    var results = [CPMutableArray arrayWithObject:tile];
    for (i=0; i<4; i++)
    {
        var neighbor = neighbors[i];

        var neighboringTile = [_rootLayer hitTest:CGPointMake(centerOfTile.x + neighbor.x, centerOfTile.y + neighbor.y -26)];

        if ([_buttonArray containsObject:neighboringTile])
            [results addObject:neighboringTile];
    }

  return results;
}

/* Animation code */

- (float)_showLightFlourish
{
		
    var lightDelay = 0.0;
    var rowIndex, columnIndex;
    
    // up lit
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
		
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1) -1);
        }
        lightDelay += 0.05;
    }
    
    // up dark
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1)-1);

        }
        lightDelay += 0.05;
    }
    
    // left lit
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1)-1);

        }
        lightDelay += 0.05;
    }
    
    // left dark
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1)-1);

        }
        lightDelay += 0.05;
    }
    
    // one by one lit
    var previousDelay = lightDelay;
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1)-1);

            lightDelay += 0.05;
        }
    }
    lightDelay = previousDelay + 0.05;
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
			setTimeout(animateOnLight, lightDelay*1000, (rowIndex * ROW_COUNT) + (columnIndex + 1)-1);

            lightDelay += 0.05;
        }
    }
	
	return lightDelay;
}

-(CPTimeInterval)_animateWinSequence
{
	var winLightSequence = new Array(27);
	winLightSequence[0] = 1;
	winLightSequence[1] = 6; 
	winLightSequence[2] = 11; 
	winLightSequence[3] = 16; 
	winLightSequence[4] = 21; 
	winLightSequence[5] = 22; 
	winLightSequence[6] = 23; 
	winLightSequence[7] = 24; 
	winLightSequence[8] = 25; 
	winLightSequence[9] = 20; 
	winLightSequence[10] = 15; 
	winLightSequence[11] = 10; 
	winLightSequence[12] = 5; 
	winLightSequence[13] = 4; 
	winLightSequence[14] = 3; 
	winLightSequence[15] = 2; 
	winLightSequence[16] = 7; 
	winLightSequence[17] = 12; 
	winLightSequence[18] = 17; 
	winLightSequence[19] = 18; 
	winLightSequence[20] = 19; 
	winLightSequence[21] = 14; 
	winLightSequence[22] = 9; 
	winLightSequence[23] = 8; 
	winLightSequence[24] = 7; 
	winLightSequence[25] = 12; 
	winLightSequence[26] = 13;
	
	var winLightSequenceDelay;
	winLightSequenceDelay = [self _executeLightSequence:winLightSequence count:27 delayBetweenLights:0.05];
	
	return winLightSequenceDelay;
}

- (CPTimeInterval)_executeLightSequence:(CPArray)lightSequence count:(int)count delayBetweenLights:(CPTimeInterval)lightDelay
{
    var currentDelay = 0.0;
    var lightIndex = 0;
    while (lightIndex < count) {
        setTimeout(animateOnLight, currentDelay*1000, lightSequence[lightIndex++]-1);
        currentDelay += lightDelay;
    }
    currentDelay += lightDelay;
    
    if (currentDelay)
    return currentDelay;
}


@end
