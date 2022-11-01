{SinOscFB.ar(440, 0.5, 0.2)}.play;

SystemClock.sched(5, { "hello".postln});

t = TempoClock.default;

thisThread.clock
SystemClock.beats
AppClock.beats

(
var timeNow;
t.tempo = 2;
timeNow = t.beats;
"Time is now: ".post; timeNow.postln;
"Scheduling for: ".post; (timeNow + 5).postln;
TempoClock.default.schedAbs(timeNow +5,
	{ "Time is later: ".post; thisThread.clock.beats.postln; nil
});
)


(
r = Routine({
    "abcde".yield;
    "fghij".yield;
    "klmno".yield;
    "pqrst".yield;
    "uvwxy".yield;
    "z{|}~".yield;
});
)

r.next;    // get the next value from the Routine
6.do({ r.next.postln });

(
r = Routine({
    var delta;
    loop {
        delta = rrand(1, 3) * 0.5;
        "Will wait ".post; delta.postln;
        delta.yield;
    }
});
)

r.next;

TempoClock.default.sched(0, r);

r.stop;

(
SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1, out|
	var sig;
	sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain),
doneAction: Done.freeSelf);
	Out.ar(out, sig ! 2);
}).add;

r = Routine({
	var delta;
	loop {
		delta = exprand(0.5, 3.5) * 0.5;
		Synth(\singrain, [freq: exprand(200, 800), amp: rrand(0.1, 0.5),
			sustain: delta * 0.8]);
		delta.yield;
	}
});
)

r.play
r.stop

(
t = Task({
	loop {
		[60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
			Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
			0.125.wait;
		});
	}
}).play;
)

t.stop
t.play

(
f = {
	Task({
		loop {
			[60, 62, 63, 65, 67, 69, 71, 72].do({ |midi2|
				Synth(\singrain, [freq: midi2.midicps, amp: 0.2, sustain: 0.1]);
				0.25.wait;
			});
		}
	});
}
)

t = f.value.play(quant: 4);
u = f.value.play(quant: [4, 0.75]);
v = f.value.play(quant: [3, 0.5]);

(
var midi, dur;
midi = Routine({
	[72, 75, 74, 72, 72, 71, 72, 71, 72, 75, 74, 72, 76, 77, 76, 77].do({ |midi| midi.yield});});
dur = Routine({
	[0.5, 0.5, 1, 1, 0.25, 1.75, 0.25, 1.75, 0.5, 0.5, 1, 1, 0.25, 1.75, 0.25, 1.75].do({ |dur| dur.yield });});

SynthDef(\smooth, { |freq = 440, feedback = 0, sustain = 1, amp = 0.25, out|
	var sig;
	sig = SinOscFB.ar(freq, feedback, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.05),
		doneAction: Done.freeSelf);
	Out.ar(out, sig ! 2)
}).add;

r = Task({
	var delta;
	while {
		delta = dur.next;
		delta.notNil;
	} {
		Synth(\smooth, [freq: midi.next.midicps, feedback: exprand(0.1, 1), sustain: delta]);
		delta.yield;
	}
}).play;//(quant: TempoClock.default.beats + 1.0);
)

(
SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var sig, env;
    env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
}).add;

TempoClock.default.tempo = 132/60;

p = Pxrand([
    Pbind(
        \instrument, \bass,
        \midinote, 36,
        \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
        \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 48, 36], 1),
        \dur, Pseq([0.25, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 39, 36, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    )
], inf).play(quant: 1);
)

// totally cheesy, but who could resist?
(
SynthDef(\kik, { |out, preamp = 1, amp = 1|
    var freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
        sig = SinOsc.ar(freq, 0.5pi, preamp).distort * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2);
}).add;

// before you play:
// what do you anticipate '\delta, 1' will do?
k = Pbind(\instrument, \kik, \delta, 5, \preamp, 4.5, \amp, 0.32).play(quant: 12);
)

p.stop;
k.stop;











