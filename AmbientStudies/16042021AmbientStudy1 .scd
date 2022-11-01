MIDIClient.init
MIDIClient.sources
MIDIIn.connect(3, MIDIClient.sources.at(3));

(
SynthDef("sine2", {
	| out, freq=200, atk=0.5, rel=5, amp=1, pan=0 |
	var sig, ovr1, ovr2, ovr3, ovr4, env, mod, modenv, x;
	modenv = EnvGen.kr(Env.new([0,5,0], [13,13], 'lin'));
	mod = SinOsc.kr(modenv, 0, 0.2);
	sig = SinOsc.ar(freq, mul:0.5);
	ovr1 = SinOsc.ar(freq * 2, 0, mod);
	ovr2 = SinOsc.ar(freq * 3/2, 0, 0.2);
	ovr3 = SinOsc.ar(freq * 81/64, 0, mod);
	ovr4 = SinOsc.ar(freq * 32/27, 0, 0.1);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig + ovr1 + ovr2 + ovr3 +ovr4 , pan, amp);
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

x = Synth("sine2");

(
~noteOn = {arg src, chan, num, vel;
    x.set(\freq, num.midicps / 4.0);
    //x.set(\gate, vel / 200 );
    //x.set(\formfreq, vel / 127 * 1000);
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = { arg src,chan,num,vel;
    x.set(\gate, 0.0);
};
MIDIIn.addFuncTo(\noteOff, ~noteOff);
)

//cleanup
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\bend, ~bend);



modenv = EnvGen.kr(Env.new([0,5,0], [3,3], 'lin'));
mod = SinOsc.kr(2, 0, 0.2);
ovr1 = SinOsc.ar(freq * 2, 0, mod);


x.set(\freq, 300);

(
Pdef(\sineseq,
	Pbind(
		\instrument, \sine,
		\dur, Pexprand(0.2, 1),
		\freq, Pexprand(200, 800),
		\atk, Pexprand(0.02, 1),
		\rel, Pexprand(1, 7);
)).stop;
)


(
p = Pbind(
	\instrument, \sine2,
	\degree, Pseq([0,0,4,4,5,5,4], 1),
	\dur, Pseq([5,5,5,0.5,5,5,0.5,1],1)
).play;
)

Pslide([1,2,3,4,5,6,7,8], 10, 3, 1, 0, false).clump(3).asStream.all;

(
p = Pbind(
	\instrument, \sine2,
	\degree, Pslide((-6, -4 .. 12), 8, 3, 1, 0),
	\dur, Pseq([0.1,0.1,0.2],inf),
	\sustain, 1.15
).play;
)


// 1) =========  LFO  ==========



// Tremolo - variations in amplitude

(

// LFO (Low Frequency Oscillator) synthesis


// mouseX is the frequency of the tremolo

{

var modulator, carrier;

modulator = SinOsc.kr(MouseX.kr(2,20), 0, 0.4);

carrier = SinOsc.ar(333, 0, modulator);


carrier!2 // the output

}.play

)



// Vibrato - variation in pitch


(

// LFO (Low Frequency Oscillator) synthesis


// mouseX is the power of the vibrato

// mouseY is the frequency of the vibrato

{

var modulator, carrier;

modulator = SinOsc.ar(MouseY.kr(20, 5), 0, MouseX.kr(5, 20));

carrier = SinOsc.ar(440 + modulator, 0, 1);

carrier!2 // the output

}.play

)


(
SynthDef.new(\sine, {
	arg freq=200, atk=0.5, rel=5, amp=1, pan=0;
	var sig, ovr1, ovr2, ovr3, ovr4, env;
	sig = SinOsc.ar(freq, mul:0.5);
	ovr1 = SinOsc.ar(freq * 2, 0, 0.2);
	ovr2 = SinOsc.ar(freq * 3/2, 0, 0.2);
	ovr3 = SinOsc.ar(freq * 81/64, 0, 0.1);
	ovr4 = SinOsc.ar(freq * 32/27, 0, 0.1);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig + ovr1 + ovr2 + ovr3 +ovr4 , pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)