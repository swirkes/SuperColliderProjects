(
SynthDef.new(\sine, {
	arg freq=200, atk=0.5, rel=5, amp=0.71, pan=0;
	var sig, ovr1, ovr2, ovr3, ovr4, env;
	sig = SinOsc.ar(freq, mul:0.5);
	ovr1 = SinOsc.ar(freq * 2, 0, 0.2);
	ovr2 = SinOsc.ar(freq * 3/2, 0, 0.2);
	ovr3 = SinOsc.ar(freq * 81/64, 0, 0.1);
	ovr4 = SinOsc.ar(freq * 32/27, 0, 0.1);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig + ovr1 + ovr2 + ovr3 +ovr4 , pan, amp);
	sig = sig * env;
	Out.ar([0,1], sig);
}).add;
)

x = Synth.new(\sine);
x.set(\freq, 300);

(
Pdef(\sineseq,
	Pbind(
		\instrument, \sine,
		\dur, Pexprand(0.2, 1),
		\freq, Pseq([330, 330*2, 440], 1),
		\atk, Pexprand(0.02, 1),
		\rel, Pexprand(1, 7);
)).play;
);

a = Pseries(0, 1, 10);
a = a.asStream;
a.next;

r = a.asStream;
r.next
q = a.asStream;

[r.next, q.next]

Pseq([1,2,3],4).asStream.all;
Pser([1,2,3],7).asStream.all;


(
p = Pbind(
	\degree, Pseq([0,0,4,4,5,5,4], 1),
	\dur, Pseq([0.5,0.5,0.5,0.5,0.5,0.5,1],1)
).play;
)

Pslide([1,2,3,4,5,6,7,8], 10, 3, 1, 0, false).clump(3).asStream.all;

(
p = Pbind(
	\degree, Pslide((-6, -4 .. 12), 8, 3, 1, 0),
	\dur, Pseq([0.1,0.1,0.2],inf),
	\sustain, 0.15
).play;
)

(
p = Pbind(
	\degree, Pseq([0,1], inf),
	\dur, 0.25
).play;
)
p.stop;

(
p = Pbind(
	\degree, Pseq([0,0,4,4,5,5,4], 1),
	\dur, Pseq([0.5,0.5,0.5,0.5,0.5,0.5,1],1)
).asStream;
)


p.next(Event.new);

s = Pbind(\degree,Pwhite(0,7,inf),\dur,0.25,\legato,1).play;
s.stop;

p = Pmono(\default,\degree,Pwhite(0,7,inf),\dur,0.25,\legato,1).play;



(freq:293.3333,amp:0.2,pan:-0.7).play

SynthDef(\harpsi, { |outbus = 0, freq = 440, amp = 0.1, gate = 1|
    var out;
    out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp *
        Pulse.ar(freq, 0.25, 0.75);
    Out.ar(outbus, out ! 2);
}).add;    // see below for more on .add

(
p = Pbind(
        // Use \harpsi, not \default
    \instrument, \harpsi,
	\degree, Pseq([0.1,0,1,1.1,2.1,2], 2),
    \dur, 0.25
).play;
)


(
// first, pitches ascending by 1-3 semitones, until 2 octaves are reached
var    pitches = Pseries(0, Pconst(24, Pwhite(1, 3, inf)), inf).asStream.all,
        // randomly block 1/3 of those
    mask = pitches.scramble[0 .. pitches.size div: 3];

p = Pbind(
    \arpeg, Pseq(pitches[ .. pitches.size - 2] ++ pitches.reverse[ .. pitches.size - 2], inf),
        // if the note is found in the mask array, replace it with Rest
        // then that note does not sound
    \note, Pif(Pfunc { |event| mask.includes(event[\arpeg]) }, Rest(0), Pkey(\arpeg)),
    \octave, 4,
    \dur, 0.125
).play;
)

p.stop;
