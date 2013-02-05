//
//  ListenerViewController.h
//  SafeSound
//
//  Created by Demetri Miller on 10/25/10.
//  Copyright 2010 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class RIOInterface;
@class ToneGenerator;

@interface ListenerViewController : UIViewController {
@public
	IBOutlet UILabel *currentPitchLabel;
	IBOutlet UIButton *listenButton;
	IBOutlet UIButton *play19500;
	IBOutlet UIButton *play20000;
	
	BOOL isListening;
    BOOL isPlaying;
    BOOL run;
    BOOL noResponse;
    BOOL evaluation;
    int data;
    int datalen;
	RIOInterface *rioRef;
    ToneGenerator *generator;
	uint64_t count;
    uint64_t *vals;
    uint64_t st1;
    
	NSMutableString *key;
	float currentFrequency;
	NSString *prevChar;
}

@property(nonatomic, retain) UILabel *currentPitchLabel;
@property(nonatomic, retain) UIButton *listenButton;
@property(nonatomic, retain) UIButton *play19500;
@property(nonatomic, retain) UIButton *play20000;
@property(nonatomic, retain) NSMutableString *key;
@property(nonatomic, retain) NSString *prevChar;
@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) float currentFrequency;
@property(assign) BOOL isListening;
@property(assign) BOOL isPlaying;
@property(assign) BOOL noResponse;
@property(assign) uint64_t *vals;


#pragma mark Listener Controls
- (IBAction)toggleListening:(id)sender;
- (IBAction)togglePlay19500:(id)sender;
- (IBAction)togglePlay20000:(id)sender;
- (IBAction)sendRequest:(id)sender;
- (IBAction)sendData:(id)sender;
- (IBAction)toggleEvaluation;
- (void)startListener;
- (void)stopListener;
- (void) request;

- (void)frequencyChangedWithValue:(float)newFrequency;
- (void)updateFrequencyLabel;
- (void) newfire;
- (void) fire;

@end
