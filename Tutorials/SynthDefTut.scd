{ SinOsc.ar([[76.5, 76.75, 77], [(76.5*3), (76.75*3), (77*3)]], 0, 0.20) }.play;
{ SinOsc.ar([76.5*15, 76.75*15, 77*15], 0, 0.07) }.play;
{ SinOsc.ar([76.5/2, 77/2], 0, 0.5) }.play;


{ SinOsc.ar([[83,83.5, 83.75], [(83*3), (83.5*3), (83.75)]], 0, 0.20) }.play;
{ SinOsc.ar([76.5*15, 76.75*15, 77*15], 0, 0.07) }.play;
{ SinOsc.ar([76.5/2, 77/2], 0, 0.5) }.play;


SynthDef.new("tutorial-SinOsc", { |out| Out.ar(out, SinOsc.ar(330, 0, 0.5)) }).play


(
SynthDef.new("tutorial-SinOsc-stereo", { arg freq1=330, freq2=333, out=0;
	var outArray;
	outArray = [SinOsc.ar(freq1, 0, 0.2),SinOsc.ar(freq2, 0, 0.2)];
	Out.ar(out, outArray)
}).add;
)

s.scope
x.free
x = Synth.new("tutorial-SinOsc-stereo")
x.set("freq1", 300, "freq2", 400);
x.set("freq1", 330, "freq2", 333);
x.free


(
SynthDef.new("tutorial-args", { arg freq = 440, amp=0.01, out = 0;
    Out.ar(out, SinOsc.ar(freq, 0, amp));
}).add;
)
s.scope; // scope so you can see the effect
x = Synth.new("tutorial-args");
x.set("freq", 660);
x.set("freq", 320, "out", 0, "amp", 0.02);
x.free;

{ Blip.ar(XLine.kr(20000,200,6),100,0.2) }.scope(1);
{ Blip.ar(XLine.kr(100,15000,6),100,0.2) }.scope(1); // no aliasing
// modulate number of harmonics
{ Blip.ar(200,Line.kr(1,100,20),0.2) }.scope(1);

{ Klang.ar(`[ [800, 1000, 1200],[0.3, 0.3, 0.3],[pi,pi,pi]], 1, 0) * 0.4}.scope(1);

( // using default window
{
    var trigrate, winsize, trig;
    trigrate = MouseX.kr(2, 120);
    winsize = trigrate.reciprocal;
    trig = Impulse.ar(trigrate);
    GrainSin.ar(2, trig, winsize, TRand.ar(440.0, 880.0, trig), LFNoise1.kr(0.2),
        -1, 512, 0.2)
}.scope(2, zoom: 4);
)
​
b = Buffer.sendCollection(s, Env([0, 1, 0], [0.5, 0.5], [8, -8]).discretize, 1);
​
( // using user supplied window
{
    var trigrate, winsize, trig;
    trigrate = MouseX.kr(2, 120);
    winsize = trigrate.reciprocal;
    trig = Impulse.ar(trigrate);
    GrainSin.ar(2, trig, winsize, TRand.ar(379.0, 737.0, trig), LFNoise1.kr(0.2),
        b, 512, 0.2)
}.scope(2, zoom: 4);
)