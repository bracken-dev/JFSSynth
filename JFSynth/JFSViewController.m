//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthController.h"
#import "JFSEnvelopeGenerator.h"
#import "JFSOscillator.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet UISlider *cutoffSlider;
@property (weak, nonatomic) IBOutlet UISlider *resonanceSlider;
@property (weak, nonatomic) IBOutlet UISlider *cutoffLFOSlider;
@property (weak, nonatomic) IBOutlet UISlider *lfoAmountSlider;

@property (weak, nonatomic) IBOutlet UISlider *oscOneCoarseSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscTwoCoarseSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscOneFineSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscTwoFineSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSEnvelopeView *filterEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;

@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.keyBoardView.delegate = self;
    
    self.ampEnvelopeView.dataSource = self;
    self.ampEnvelopeView.delegate = self;
    
    self.filterEnvelopeView.dataSource = self;
    self.filterEnvelopeView.delegate = self;
    
    JFSSynthController *audioManager = [JFSSynthController sharedController];
    
    self.velocityPeakSlider.minimumValue = 0.001;
    self.velocityPeakSlider.maximumValue = 127.0;
    self.velocityPeakSlider.value = 60;
    
    self.cutoffSlider.minimumValue = [audioManager minimumCutoff];
    self.cutoffSlider.maximumValue = [audioManager maximumCutoff];
    self.cutoffSlider.value = audioManager.cutoffLevel;
    
    self.cutoffLFOSlider.minimumValue = [audioManager minimumCutoffLFO];
    self.cutoffLFOSlider.maximumValue = [audioManager maximumCutoffLFO];
    
    self.resonanceSlider.minimumValue = [audioManager minimumResonance];
    self.resonanceSlider.maximumValue = [audioManager maximumResonance];
    self.resonanceSlider.value = audioManager.resonanceLevel;
    
    self.lfoAmountSlider.value = [audioManager cuttoffLFOAmount];
    
    self.oscOneCoarseSlider.minimumValue = -1;
    self.oscOneCoarseSlider.maximumValue = 1;
    self.oscTwoCoarseSlider.minimumValue = -1;
    self.oscTwoCoarseSlider.maximumValue = 1;
    self.oscOneFineSlider.minimumValue = 0;
    self.oscOneFineSlider.maximumValue = 1;
    self.oscTwoFineSlider.minimumValue = 0;
    self.oscTwoFineSlider.maximumValue = 1;
    
    self.oscOneCoarseSlider.value = audioManager.oscillatorOne.coarse;
    self.oscTwoCoarseSlider.value = audioManager.oscillatorTwo.coarse;
    self.oscOneFineSlider.value = audioManager.oscillatorOne.fine;
    self.oscTwoFineSlider.value = audioManager.oscillatorTwo.fine;
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(refreshViews) userInfo:nil repeats:YES];
    
    [self.refreshTimer fire];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

 - (void)dealloc
{
    [self.refreshTimer invalidate];
}

#pragma mark - UI Refresh

- (void)refreshViews
{
    [self.ampEnvelopeView updateStage:[JFSSynthController sharedController].ampEnvelopeGenerator.envelopeState - 1];
    [self.filterEnvelopeView updateStage:[JFSSynthController sharedController].filterEnvelopeGenerator.envelopeState - 1];
}

#pragma mark - IBAction

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedController].oscillatorOne setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)waveTypeTwoControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedController].oscillatorTwo setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)velocitySliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController].ampEnvelopeGenerator updatePeakWithMidiVelocity:slider.value];
}

- (IBAction)cutoffSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedController].cutoffLevel = slider.value;
}

- (IBAction)resonanceSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedController].resonanceLevel = slider.value;
}
- (IBAction)cutoffLFOSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedController].cutoffLFOFrequency = slider.value;
}

- (IBAction)filterLFOAmountSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateLFOAmount:slider.value];
}

- (IBAction)oscOneCoarseSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateOscillator:[JFSSynthController sharedController].oscillatorOne coarse:slider.value];
}

- (IBAction)oscTwoCoarseSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateOscillator:[JFSSynthController sharedController].oscillatorTwo coarse:slider.value];
}

- (IBAction)oscOneFineSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateOscillator:[JFSSynthController sharedController].oscillatorOne fine:slider.value];
}

- (IBAction)oscTwoFineSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateOscillator:[JFSSynthController sharedController].oscillatorTwo fine:slider.value];
}

- (IBAction)oscillatorVolumeSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController] updateVolumeForOscillatorAtIndex:slider.tag value:slider.value];
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.attackTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.attackTime;
}

- (Float32)decayTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.decayTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeakForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.sustainLevel / [JFSSynthController sharedController].ampEnvelopeGenerator.peak;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.sustainLevel / [JFSSynthController sharedController].filterEnvelopeGenerator.peak;
}

- (Float32)releaseTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.releaseTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return [JFSSynthController sharedController].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint value:(Float32)value
{
    JFSEnvelopeGenerator *envelopeGenerator;
    
    if (envelopeView == self.ampEnvelopeView) {
        envelopeGenerator = [JFSSynthController sharedController].ampEnvelopeGenerator;
    } else {
        envelopeGenerator = [JFSSynthController sharedController].filterEnvelopeGenerator;
    }
    
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            envelopeGenerator.attackTime = value;
            break;
        case JFSEnvelopeViewPointDecay:
            envelopeGenerator.decayTime = value;
            break;
        case JFSEnvelopeViewPointSustain:
            [envelopeGenerator updateSustainWithMidiVelocity:value * 127.];
            break;
        case JFSEnvelopeViewPointRelease:
            envelopeGenerator.releaseTime = value;
            break;
        default:
            break;
    }
}

#pragma mark - JFSKeyboardViewDelegate

- (void)keyPressedWithMidiNote:(int)midiNote
{
    double frequency = pow(2, (double)(midiNote - 69) / 12) * 440;
    
    [[JFSSynthController sharedController] playFrequency:frequency];
}

- (void)keyReleasedWithMidiNote:(int)midiNote
{
    [[JFSSynthController sharedController] stopPlaying];
}

@end
