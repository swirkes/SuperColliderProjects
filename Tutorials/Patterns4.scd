(
TempoClock.default.tempo = 160;
p = Pbind(
	\degree, Pseq([
		Pseries({rrand(0,7)}, 1, {rrand(4,8)}),
		Pseries({rrand(0,7)}, 1, {rrand(4,8)}),
		Pseries({rrand(7,14)}, -1, {rrand(4,8)})
	], inf),
	\dur, 0.125
).play;
)

(
SynthDef(\bass, {|out, freq=440,gate=1,amp=0.5,slideTime=0.17,ffreq=1100,
	width=0.15, detune=1.005, preamp=4|
	var sig,
	env = Env.adsr(0.01, 0.3, 0.4, 0.1);
	freq = Lag.kr(freq, slideTime);
	sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
	* EnvGen.kr(env, gate, doneAction: Done.freeSelf);
	sig = LPF.ar(sig, ffreq);
	Out.ar(out, sig ! 2)
}).add;
)

(
TempoClock.default.tempo = 132/60;
p = Pxrand([
	Pbind(
		\instrument, \bass,
		\midinotes, 36,
		\dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
		\legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
		\amp, 0.5, \detune, 1.005
	),
	Pmono(\bass,        // octave jump
        \midinote, Pseq([36, 48, 36], 1),
        \dur, Pseq([0.25, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,        // tritone jump
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,        // diminished triad
        \midinote, Pseq([36, 39, 36, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    )
], inf).play(quant: 1);
)

// scale degree segments, every fifth choice is odd-numbered only (descending)
(
var    n = 10,
    scaleSegments = Array.fill(n, { |i|
        if(i.odd) {
            Pseries(11, -1, rrand(5, 10))
        } {
            Pseries(rrand(-4, 4), 1, i+2)
        }
    });

TempoClock.default.tempo = 1;
p = Pbind(
    \degree, Pswitch(scaleSegments, Pseq([Pwhite(0, n-1, 4), Pwhite(0, n-1, 1).select(_.odd)], inf)),
    \dur, 5/64
).play;
)

p.stop;

(
// this SynthDef has a strong attack, emphasizing the articulation
SynthDef(\sawpulse, { |out, freq = 440, gate = 0.5, plfofreq = 6, mw = 0, ffreq = 2000, rq = 0.3, freqlag = 0.05, amp = 1|
    var sig, plfo, fcurve;
    plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
    freq = Lag.kr(freq, freqlag) * plfo;
    fcurve = EnvGen.kr(Env.adsr(0, 0.3, 0.1, 20), gate);
    fcurve = (fcurve - 1).madd(0.7, 1) * ffreq;
    sig = Mix.ar([Pulse.ar(freq, 0.9), Saw.ar(freq*1.007)]);
    sig = RLPF.ar(sig, fcurve, rq)
        * EnvGen.kr(Env.adsr(0.04, 0.2, 0.6, 0.1), gate, doneAction: Done.freeSelf)
        * amp;
    Out.ar(out, sig ! 2)
}).add;
)

(
TempoClock.default.tempo = 128/60;

// Pmul does only one thing here: take ~amp from each event
// and replace it with ~amp * 0.4
p = Pmul(\amp, 0.4, Pfsm([
    #[0, 3, 1],        // starting places
    PmonoArtic(\sawpulse,
        \midinote, Pseq([78, 81, 78, 76, 78, 76, 72, 71, 69, 66], 1),
        \dur, Pseq(#[0.25, 1.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.3, 1.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2],1 ),
        \amp, Pseq(#[1, 0.5, 0.75, 0.5, 0.75, 0.5, 0.75, 0.5, 0.75, 0.5], 1),
        \mw, Pseq([0, 0.03, Pseq(#[0], inf)], 1)
    ), #[1, 2, 3, 4, 7],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([64, 66, 69, 71, 72, 73], 1),
        \dur, Pseq(#[0.25], 6),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 0.5, 0.5, 0.5], 1),
        \mw, 0
    ), #[1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([69, 71, 69, 66, 64, 69, 71, 69], 1),
        \dur, Pseq(#[0.125, 0.625, 0.25, 0.25, 0.25, 0.25, 0.25, 0.75], 1),
        \sustain, Pseq(#[0.2, 0.64, 0.2, 0.2, 0.2, 0.3, 0.3, 0.75], 1),
        \amp, Pseq(#[0.5, 0.75, 0.5, 0.5, 0.5, 1, 0.5, 0.5], 1),
        \mw, 0
    ), #[0, 1, 1, 1, 1, 3, 3, 3, 3, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([72, 73, 76, 72, 71, 69, 66, 71, 69], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.083, 0.083, 0.084, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.1, 0.07, 0.07, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 1, 0.3, 0.3, 0.75, 0.75, 0.5], 1),
        \mw, 0
    ), #[1, 1, 1, 1, 3, 3, 4, 4, 4],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([64, 66, 69, 71, 72, 73, 71, 69, 66, 71, 69, 66, 64, 69], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.125, 0.375, 0.166, 0.166, 0.168,
                0.5, 0.166, 0.166, 0.168, 0.5], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.14, 0.4, 0.2, 0.2, 0.2, 0.6, 0.2, 0.2, 0.2, 0.5],1),
        \amp, Pseq(#[0.5, 0.5, 0.6, 0.8, 1, 0.5, 0.5, 0.5, 0.5, 1,
            0.5, 0.5, 0.5, 0.45], 1),
        \mw, 0
    ), #[0, 1, 1, 1, 1, 3, 3, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([72, 73, 76, 78, 81, 78, 83, 81, 84, 85], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.125, 1.125], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.95, 0.25, 0.95, 0.25, 0.2, 1.13], 1),
        \amp, Pseq(#[0.7, 0.5, 0.5, 0.5, 0.7, 0.5, 0.8, 0.5, 1, 0.5], 1),
        \mw, Pseq([Pseq(#[0], 9), 0.03], 1)
    ), #[6, 6, 6, 8, 9, 10, 10, 10, 10, 11, 11, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([83, 81, 78, 83, 81, 78, 76, 72, 73, 78, 72, 72, 71], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
                0.25, 2], 1),
        \sustain, Pseq(#[0.3, 0.3, 0.2, 0.3, 0.3, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 2], 1),
        \amp, Pseq(#[0.5, 0.5, 0.5, 0.8, 0.5, 0.5, 0.5, 0.8, 0.5, 0.8, 0.5,
                1, 0.4], 1),
        \mw, Pseq([Pseq([0], 12), 0.03], 1)
    ), #[0, 7, 7, 7, 7, 7, 3, 3, 3, 3],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([69, 71, 72, 71, 69, 66, 64, 69, 71], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.166, 0.167, 0.167, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 0.2, 0.3, 0.2, 0.2, 0.2, 0.14, 0.3, 0.2], 1),
        \amp, Pseq(#[0.5, 0.5, 0.8, 0.5, 0.5, 0.5, 0.5, 0.8, 0.5], 1)
    ), #[3, 3, 3, 4, 4, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([84, 85, 84, 84, 88, 84, 83, 81, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.125, 0.535, 0.67, 1.92, 0.25, 0.166, 0.167, 0.167,
                0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 3.12, 0.2, 0.2, 0.2, 0.2, 0.2, 0.15, 0.3, 0.2, 0.2, 0.2,
                0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.8, 0.8, 0.8, 1, 1, 0.8, 0.8, 1, 0.8, 0.8, 0.8,
                1, 0.8], 1),
        \mw, Pseq([0, 0.005, 0.005, 0.06, Pseq(#[0], 10)], 1)
    ), #[10, 10, 10, 11, 11, 11, 11, 12, 12, 12],

        // same as #4, 8va
    PmonoArtic(\sawpulse,
        \midinote, Pseq(([64, 66, 69, 71, 72, 73, 71, 69, 66, 71, 69, 66, 64, 69]+12), 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.125, 0.375, 0.166, 0.166, 0.168,
                0.5, 0.166, 0.166, 0.168, 0.5], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.14, 0.4, 0.2, 0.2, 0.2, 0.6, 0.2, 0.2, 0.2, 0.5],1),
        \amp, Pseq(#[0.5, 0.5, 0.6, 0.8, 1, 0.5, 0.5, 0.5, 0.5, 1,
            0.5, 0.5, 0.5, 0.45], 1),
        \mw, 0
    ), #[11, 11, 11, 11, 11, 12, 12],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([81, 84, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.25], 8),
        \sustain, Pseq(#[0.2, 0.3, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[0.5, 1, 0.5, 0.5, 0.6, 0.5, 0.8, 0.5], 1),
        \mw, 0
    ), #[0, 9, 9, 11, 11, 12, 12, 12, 12, 12],

        // same as #1, 8va
    PmonoArtic(\sawpulse,
        \midinote, Pseq(([64, 66, 69, 71, 72, 73]+12), 1),
        \dur, Pseq(#[0.25], 6),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 0.5, 0.5, 0.5], 1),
        \mw, 0
    ), #[6, 6, 8, 9, 9, 9, 9, 10, 10, 10, 10, 13, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([78, 81, 83, 78, 83, 84, 78, 84, 85], 1),
        \dur, Pseq(#[0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 1.75], 1),
        \sustain, Pseq(#[0.2, 0.3, 0.2, 0.2, 0.3, 0.2, 0.2, 0.3, 1.75], 1),
        \amp, Pseq(#[0.4, 0.8, 0.5, 0.4, 0.8, 0.5, 0.4, 1, 0.8], 1),
        \mw, Pseq([Pseq([0], 8), 0.03], 1)
    ), #[8, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([88, 84, 83, 81, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.25, 0.166, 0.167, 0.167,
                0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 0.2, 0.2, 0.15, 0.3, 0.2, 0.2, 0.2,
                0.3, 0.2], 1),
        \amp, Pseq(#[1, 1, 0.8, 0.8, 1, 0.8, 0.8, 0.8,
                1, 0.8], 1),
        \mw, 0
    ), #[10]
], inf)).play;
)

p.stop;

(
TempoClock.default.tempo = 1;
p = Pbind(
        // translation: if(0.7.coin) { rrand(-7, 0) } { rrand(7, 14 }
    \degree, Pif(Pwhite(0.0, 1.0, inf) < 0.7, Pwhite(-7, 0, inf), Pwhite(7, 14, inf)),
    \dur, 0.25
).play;
)

p.stop;


// random pitches in two distinct ranges; use a coin toss to decide which for this event
// 70% low, 30% high
(
TempoClock.default.tempo = 1;
p = Pbind(
    \degree, Pswitch([Pwhite(7, 14, inf), Pwhite(-7, 0, inf)], Pfunc { 0.5.coin.binaryValue }),
    \dur, 0.25
).play;
)

