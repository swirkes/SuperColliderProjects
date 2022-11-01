///////////////////////////////////////
//performance GUI for countdown timer//
///////////////////////////////////////

//"I’m curious about creating a countdown box that shows the seconds until the next event is automatically triggered. (Trying to think of different ways for triggering, especially since a midi/usb pedal is a little difficult for a vibraphonist to use.)"

(
Window.closeAll;

w = Window.new("countdown timer", Rect(500,50,610,100))
.alwaysOnTop_(true)
.front;

n = NumberBox(w, w.view.bounds)
.background_(Color.gray(0.1))
.stringColor_(Color.gray(0.8))
.font_(Font(Font.defaultMonoFace, 100))
.string_(0.asTimeString.keep(10))
.canFocus_(false);

s.waitForBoot({

	SynthDef.new(\tone, {
		var sig;
		sig = SinOsc.ar(\freq.kr(400));
		sig = sig * Env.perc.kr(2);
		sig = Pan2.ar(sig, 0, 0.4);
		Out.ar(\out.ir(0), sig);
	}).add;

	s.sync;

	~piece = Routine.new({

		Synth.new(\tone, [\freq, 400]);

		~startCountdown.value(8,n);
		8.wait;

		Synth.new(\tone, [\freq, 700]);

		~startCountdown.value(5,n);
		5.wait;

		Synth.new(\tone, [\freq, 250]);

	});

	~startCountdown = {
		arg time=10, nb;
		~countdown.stop;
		~countdown = Routine({
			while(
				{ time >= 0 },
				{
					{nb.string_(time.asTimeString.keep(10))}.defer;
					time = (time - 0.1).max(0);
					0.1.wait;
				}
			);

		}).play(TempoClock.new(1), quant:0)
	};

});
)

p = ~piece.play;

////////////////////////////////////
//scheduling GUI stuff on AppClock//
////////////////////////////////////

//"I'm using the AppClock to schedule the creation of some buttons and windows (and probably some animations as well). I've ran into some issues with some scheduled events being repeated when I wasn't specifically wanting them to repeat."

(
Window.closeAll;
w = Window.new("", Rect(1200,580,400,400))
.alwaysOnTop_(true)
.background_(Color.gray(0.1))
.front;
)

(
~make = {
	View.new(w, Rect(
		rrand(0,w.view.bounds.width-30),
		rrand(0,w.view.bounds.height-30),
		30,30)
	)
	.background_(Color.rand);
};
)

(
AppClock.sched(2, ~make);
)

///////////////

(
Window.closeAll;
w = Window.new("", Rect(1200,580,400,400))
.alwaysOnTop_(true)
.background_(Color.gray(0.1))
.front;
)

(
~make = {
	View.new(w, Rect(
		rrand(0,w.view.bounds.width-30),
		rrand(0,w.view.bounds.height-30),
		30,30)
	)
	.background_(Color.rand);
	0.5; //reschedule this many seconds later
};
)

(
AppClock.sched(2, ~make);
)

AppClock.clear; //remove all scheduled functions

///////////////

(
Window.closeAll;
w = Window.new("", Rect(1200,580,400,400))
.alwaysOnTop_(true)
.background_(Color.gray(0.1))
.front;
)

(
~make = {
	View.new(w, Rect(
		rrand(0,w.view.bounds.width-30),
		rrand(0,w.view.bounds.height-30),
		30,30)
	)
	.background_(Color.rand);
	0.5;
};
)

(
AppClock.sched(2, {~make.()});
)

//replace 0.5 with nil, re-evaluate ~make, and rescheduling will stop

///////////////

(
Window.closeAll;
w = Window.new("", Rect(1200,580,400,400))
.alwaysOnTop_(true)
.background_(Color.gray(0.1))
.front;
)

(
//reschedule exactly 20 times:
~count = 0;
~make = {
	View.new(w, Rect(
		rrand(0,w.view.bounds.width-30),
		rrand(0,w.view.bounds.height-30),
		30,30)
	)
	.background_(Color.rand);
	~count = ~count + 1;
	if (~count > 20) {nil} {0.1};
};
)

(
AppClock.sched(2, {~make.()});
)

///////////////

(
Window.closeAll;
w = Window.new("", Rect(1200,580,400,400))
.alwaysOnTop_(true)
.background_(Color.gray(0.1))
.front;
)

(
~make = {
	//do returns its receiver, so this will be rescheduled every 2 seconds
	2.do({
		View.new(w, Rect(
			rrand(0,w.view.bounds.width-30),
			rrand(0,w.view.bounds.height-30),
			30,30)
		)
		.background_(Color.rand);
	});
	//it is always smart to explicitly end clock functions with a value or nil to make sure it is appropriately rescheduled (or not rescheduled)
};
)

(
AppClock.sched(2, {~make.()});
)

AppClock.clear;

//////////////////////////////////////
//FFT processing with stereo signals//
//////////////////////////////////////

//"I am still failing to make the morphing with PV_RandWipe work with stereo files that contain true stereo information. For example morph between a stereo guitar recording and a piano stereo recording where both were recorded with AB stereo technique. I am not sure if it is possible to do anything like that."

s.boot;

~path = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/"
a = Buffer.read(s, ~path ++ "static.aiff");
b = Buffer.read(s, ~path ++ "flowerPot.aiff");

(
SynthDef.new(\stereo_randwipe, {
	var sigA, sigB, sig, chainA, chainB, chain;
	sigA = PlayBuf.ar(2, a, loop:1);
	sigB = PlayBuf.ar(2, b, loop:1);

	//array of two unique monophonic LocalBuf instances for each stereo signal
	//a stereo LocalBuf instance will not work!
	chainA = FFT({LocalBuf(4096)}!2, sigA);
	chainB = FFT({LocalBuf(4096)}!2, sigB);
	chain = PV_RandWipe(
		chainA,
		chainB,
		LFTri.kr(1/20,3).unipolar(1),
		Impulse.kr(1/10)
	);
	sig = IFFT(chain) * 0.5;
	sig = sig * Env.asr(0.01, 1, 4).kr(2, \gate.kr(1));
	Out.ar(\out.ir(0), sig);
}).add;
)

x = Synth(\stereo_randwipe);
x.set(\gate, 0);

///////////////////////
//creating a lush pad//
///////////////////////

//"The biggest thing I’m working with at the moment is creating a nice pad sound. I’d like to have a warm, full-frequency/full-body swell of harmonies at a point in my project but everything I’m coming up with sounds pretty hollow. I’ve been experimenting with sine, saw, and triangle waves at different points but I’m wondering if I need to be working with more complex waves"

//starting code:
s.boot;

(
SynthDef.new(\chimes, {

	arg freq=500, atk=0.002, sus=0, rel=1,
	pan=0, amp=0.1, out=0, out2 = 0;

	var sig, env;

	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[2,0,-2]),
		doneAction:2
	);

	sig = SinOsc.ar(freq);
	sig = Pan2.ar(sig, pan, amp) * env;
	Out.ar(out, sig);

}).add;
)

(
~sustainedIntro = Pbind(
	\instrument, \chimes,
	\atk, Pexprand(2, 3, inf),
	\sus, Pwrand([0.5, 1], [0.25, 0.75], inf),
	\rel, Pwhite(8.0, 10.0, inf),
	\amp, Pgeom(0.1, 0.95, inf),
	\midinote, Pseq([37,44,46,48,51,53,56,60,61,65,68,72,73,80],inf),
);
~player1 = ~sustainedIntro.play;
)
~player1.stop;

//ideas:
//randomly detuned cluster of multiple oscillators
//addition of non-sinusoidal waveforms (triangle, saw, filtered noise, wavetable, granular, etc)
//random amplitude modulation on each voice
//random stereophonic panning
//gentle distortion on sine waves (softclip, distort, tanh)
//iterative distortion, e.g. 3.do{sig = (sig*1.2).distort}
//lowpass filter to control presence of higher harmonics
//drown the result in delay/reverb

{SinOsc.ar(500, 0, 1.2).tanh}.plot(1/100);

(
SynthDef.new(\chimes, {

	arg freq=500, detune=0.12, atk=0.002, sus=0, rel=1,
	cf=20000, rq=1, pan=0, amp=1, out=0, out2=0, send=(-10);

	var sig, saw, noise, env, freqs;

	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[2,0,-2]),
		doneAction:2
	);

	freqs = freq * LFNoise2.kr({Rand(0.08,0.11)}!6).bipolar(detune).midiratio;
	sig = freqs.collect({
		arg n;
		var temp;
		temp = SinOsc.ar(n);
		temp = Pan2.ar(temp, Rand(-0.9,0.9));
		2.do({
			temp = temp * LFNoise2.kr(Rand(0.2,0.3)).range(4,8).dbamp;
			temp = temp.softclip;
		});
		temp;
	}).sum;

	freqs = freq * LFNoise2.kr({Rand(0.08,0.11)}!6).bipolar(detune).midiratio;
	saw = freqs.collect({
		arg n;
		var temp;
		temp = VarSaw.ar(n, Rand(0.0,1.0), Rand(0.0,0.0001));
		temp = Pan2.ar(temp, Rand(-0.9,0.9));
		2.do({
			temp = temp * LFNoise2.kr(Rand(0.2,0.3)).range(10,15).dbamp;
			temp = temp.tanh;
		});
		temp;
	}).sum;

	freqs = freq * LFNoise2.kr({Rand(0.08,0.11)}!6).bipolar(detune).midiratio;
	noise = freqs.collect({
		arg n;
		var temp;
		temp = PinkNoise.ar(1);
		temp = BPF.ar(temp, n, 0.02, 1/0.02.sqrt);
		temp = Pan2.ar(temp, Rand(-0.9,0.9));
	}).sum;

	sig = RLPF.ar(sig + saw + noise, cf, rq);
	sig = Balance2.ar(sig[0], sig[1], pan, amp) * env;
	sig = sig * 0.035;
	Out.ar(out, sig);
	Out.ar(out2, sig * send.dbamp);

}).add;

SynthDef(\verbef, {
	arg dec=3.5, mix=0.08, lpf1=2000, lpf2=6000, predel=0.025;
	var dry, wet, sig;
	dry = In.ar(\in.kr(0), 2);
	wet = In.ar(\in.kr(0), 2);
	wet = CombN.ar(wet, 0.5, predel.clip(0.0001,0.5), 0.1);
	wet = wet + CombN.ar(wet, 0.5, 0.5, 6);
	wet = 16.collect{
		var temp;
		temp = CombC.ar(
			wet,
			0.1,
			LFNoise2.kr({ExpRand(0.004,0.012)}!2).exprange(0.01,0.09),
			dec
		);
		temp = LPF.ar(temp, lpf1);
	}.sum * 0.25;
	8.do{
		wet = AllpassC.ar(
			wet,
			0.1,
			LFNoise2.kr({ExpRand(0.004,0.012)}!2).exprange(0.01,0.09),
			dec
		);
	};
	wet = LeakDC.ar(wet);
	wet = LPF.ar(wet, lpf2, 0.5);
	sig = dry.blend(wet, mix);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
s.newBusAllocators;
~bus = Bus.audio(s, 2);
~reverb = Synth(\verbef, [\in, ~bus, \out, 0, \dec, 10, \mix, 1]);

~sustainedIntro = Pbind(
	\instrument, \chimes,
	\atk, Pexprand(3, 4, inf),
	\sus, Pwrand([0.5, 1], [0.25, 0.75], inf),
	\rel, Pwhite(8.0, 10.0, inf),
	\detune, Pwhite(0.25, 0.5, inf),
	\midinote, Pseq([37,44,46,48,51,53,56,60,61,65,68,72,73,80,92],inf),
	\cf, (Pkey(\midinote).midicps * Pkey(\midinote).lincurve(28,100,8,1.1,-6)).clip(20,20000),
	\amp, Pgeom(0.5, 0.95, inf) * Pkey(\midinote).linlin(28,100,-3,-9).dbamp,
	\rq, 0.5,
	\pan, Pexprand(0.1,0.7,inf) * Pseq([-1,1],inf),
	\out, 0,
	\out2, ~bus,
	\send, -3,
);

~player1 = ~sustainedIntro.play;
)

~player1.stop;