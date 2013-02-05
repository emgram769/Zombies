//
//  ListenerViewController.m
//  SafeSound
//
//  Created by Demetri Miller on 10/25/10.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import "ListenerViewController.h"
#import "RIOInterface.h"
#import "ToneGenerator.h"
#import "ASIFormDataRequest.h"
#import <mach/mach_time.h>

@implementation ListenerViewController

@synthesize currentPitchLabel;
@synthesize listenButton;
@synthesize play19500;
@synthesize play20000;
@synthesize key;
@synthesize prevChar;
@synthesize isListening;
@synthesize isPlaying;
@synthesize	rioRef;
@synthesize currentFrequency;
@synthesize noResponse;
@synthesize vals;


static mach_timebase_info_data_t sTimebaseInfo;


#pragma mark -
#pragma mark Listener Controls
- (IBAction)toggleListening:(id)sender {
	if (isListening) {
		[listenButton setTitle:@"Begin Listening" forState:UIControlStateNormal];
		[self stopListener];
        NSLog(@"%d", rioRef->count0s);
        NSLog(@"%d", rioRef->count1s);
        
	} else {
		[listenButton setTitle:@"Stop Listening" forState:UIControlStateNormal];
		[self startListener];
	}
	
	isListening = !isListening;
}

- (IBAction)togglePlay19500:(id)sender {
	if (isPlaying) {
        [play19500 setTitle:@"Start 19500" forState:UIControlStateNormal];
		[play20000 setTitle:@"Start 19800" forState:UIControlStateNormal];
        [generator stop];
	} else {
		[play19500 setTitle:@"Stop 19500" forState:UIControlStateNormal];
		[generator playTone:19500];
	}
	
	isPlaying = !isPlaying;
}

- (IBAction)toggleEvaluation {
    if (evaluation) {
        [self stopListener];
        
        if ( sTimebaseInfo.denom == 0 ) {
            (void) mach_timebase_info(&sTimebaseInfo);
        }
        NSLog(@"%qu",vals[0] * (sTimebaseInfo.numer / sTimebaseInfo.denom));
        //printf(@"%i,  %i,  %i", vals[0] * (sTimebaseInfo.numer / sTimebaseInfo.denom), vals[1]* (sTimebaseInfo.numer / sTimebaseInfo.denom), vals[2]* (sTimebaseInfo.numer / sTimebaseInfo.denom));
    }else{
        st1 = mach_absolute_time();
        
        int length = 3;
        vals = (uint64_t *)malloc(length*sizeof(uint64_t));
        
        [self performSelectorInBackground:@selector(fire3) withObject:self];
        [self startListener];
    }
    evaluation = !evaluation;
}


- (void) fire3 {
    uint64_t start = mach_absolute_time();
    uint64_t delay  = 100000000;    //1000000 delay in nanoseconds
    uint64_t nextstart;
    
    
    
    double frequency = 19800;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    [self request2];
    
    [generator setFrequency:frequency];
    [generator play];
    
    noResponse = true;
    
    start = start * (sTimebaseInfo.numer / sTimebaseInfo.denom);
    nextstart = start + delay;
    nextstart = nextstart / (sTimebaseInfo.numer / sTimebaseInfo.denom);
    mach_wait_until(nextstart);
    [generator stop];
    start = mach_absolute_time();
    start = start * (sTimebaseInfo.numer / sTimebaseInfo.denom);
    delay = 300000000;
    nextstart = start + delay;
    nextstart = nextstart / (sTimebaseInfo.numer / sTimebaseInfo.denom);
    mach_wait_until(nextstart);
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is
    // uninitialised because it makes no sense to have a zero
    // denominator is a fraction.
    
    if (evaluation) {
        [self fire3];
    }
}

- (void) request2 {
    ASIFormDataRequest  *request = [[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:@"http://128.237.203.190:5000/process"]] autorelease];
    
    NSString *one = [NSString stringWithFormat:@"%qu",vals[0]*(sTimebaseInfo.numer / sTimebaseInfo.denom)];
    NSString *two = [NSString stringWithFormat:@"%qu",vals[1]*(sTimebaseInfo.numer / sTimebaseInfo.denom)];
    NSString *three = [NSString stringWithFormat:@"%qu",vals[2]*(sTimebaseInfo.numer / sTimebaseInfo.denom)];
    [request setPostValue:one forKey:@"value1"];
    [request setPostValue:two forKey:@"value2"];
    [request setPostValue:three forKey:@"value3"];
    [request setPostValue:@"234567" forKey:@"uniqueid"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    [currentPitchLabel setText:responseString];
    NSLog(responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
}

- (IBAction)togglePlay20000:(id)sender {
	if (isPlaying) {
        [play19500 setTitle:@"Start 19500" forState:UIControlStateNormal];
		[play20000 setTitle:@"Start 19800" forState:UIControlStateNormal];
        [generator stop];
	} else {
		[play20000 setTitle:@"Stop 19800" forState:UIControlStateNormal];
		[generator playTone:19800];
	}
	
	isPlaying = !isPlaying;
}

- (IBAction)sendRequest:(id)sender {
    [self request];
}

- (void) request {
    ASIFormDataRequest  *request = [[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:@"http://128.237.201.186:5000/"]] autorelease];
 
    [request setPostValue:@"param1" forKey:@"value1"];
    [request setPostValue:@"param2" forKey:@"value2"];
    [request startAsynchronous];
}

- (IBAction)sendData:(id)sender {
    data = 0b01010111;
    datalen = 8;
    if (!run){
        count = 0;
        run = true;
        [self performSelectorInBackground:@selector(newfire) withObject:self];
    }else{
        run = false;
    }
}

- (void) newfire {
    uint64_t start = mach_absolute_time();
    uint64_t delay  = 1000000000;    //1000000 delay in nanoseconds
    uint64_t nextstart;
    static mach_timebase_info_data_t    sTimebaseInfo;
    double frequency = 19500;
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    [generator setFrequency:frequency];
    [generator play];
    
    noResponse = true;

    start = start * (sTimebaseInfo.numer / sTimebaseInfo.denom);
    nextstart = start + delay;
    nextstart = nextstart / (sTimebaseInfo.numer / sTimebaseInfo.denom);
    mach_wait_until(nextstart);
    [generator stop];
    BOOL brkflag = false;
    start = mach_absolute_time();
    start = start * (sTimebaseInfo.numer / sTimebaseInfo.denom);
    while (noResponse){
        uint64_t current = mach_absolute_time();
        current = current * (sTimebaseInfo.numer / sTimebaseInfo.denom);
        if ((current - start) > 2000000000){
            brkflag = true;
            break;
        }
    }
    if (!brkflag){
        uint16_t end = mach_absolute_time();
        end = end * (sTimebaseInfo.numer / sTimebaseInfo.denom);
        NSLog(@"%f", (end-start)*3.4029 / 20000000);
    }
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is 
    // uninitialised because it makes no sense to have a zero 
    // denominator is a fraction.

    if (run) {
        [self newfire];
    }
}

- (void) fire{
    uint64_t start = mach_absolute_time();
    uint64_t delay  = 125000000;    //1000000 delay in nanoseconds
    uint64_t nextstart;
    static mach_timebase_info_data_t    sTimebaseInfo;
    
    int bit = data & 0b1;
    data = data >> 1;
    datalen --;
    
    double lowfreq = 19500;
    double diffreq = 300;
    
    double frequency = bit * diffreq + lowfreq;
    
    [generator setFrequency:frequency];
    [generator play];
    
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is 
    // uninitialised because it makes no sense to have a zero 
    // denominator is a fraction.

    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    

    start = start * (sTimebaseInfo.numer / sTimebaseInfo.denom);
    nextstart = start + delay;
    nextstart = nextstart / (sTimebaseInfo.numer / sTimebaseInfo.denom);
    mach_wait_until(nextstart);
    if (datalen>=0) {
        [self fire];
    }else{
        [generator stop];
        run = false;
    }
}

- (void)startListener {
	[rioRef startListening:self];
}

- (void)stopListener {
	[rioRef stopListening];
}





#pragma mark -
#pragma mark Lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	rioRef = [RIOInterface sharedInstance];
    generator = [[ToneGenerator alloc]init];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	currentPitchLabel = nil;
    listenButton = nil;
    [generator dealloc];
    [super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Key Management
// This method gets called by the rendering function. Update the UI with
// the character type and store it in our string.
- (void)frequencyChangedWithValue:(float)newFrequency{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentFrequency = newFrequency;
	[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
	
	
	/*
	 * If you want to display letter values for pitches, uncomment this code and
	 * add your frequency to pitch mappings in KeyHelper.m
	 */
	
	/*
	KeyHelper *helper = [KeyHelper sharedInstance];
	NSString *closestChar = [helper closestCharForFrequency:newFrequency];
	
	// If the new sample has the same frequency as the last one, we should ignore
	// it. This is a pretty inefficient way of doing comparisons, but it works.
	if (![prevChar isEqualToString:closestChar]) {
		self.prevChar = closestChar;
		if ([closestChar isEqualToString:@"0"]) {
		//	[self toggleListening:nil];
		}
		[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
		NSString *appendedString = [key stringByAppendingString:closestChar];
		self.key = [NSMutableString stringWithString:appendedString];
	}
	*/
	[pool drain];
	pool = nil;
	
}
		 
- (void)updateFrequencyLabel {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.currentPitchLabel.text = [NSString stringWithFormat:@"%f", self.currentFrequency];
	[self.currentPitchLabel setNeedsDisplay];
	[pool drain];
	pool = nil;
}


@end
