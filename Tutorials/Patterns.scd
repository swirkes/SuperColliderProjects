(
SynthDef.new(\overtoneSines, {
	arg out=0, freq=200, atk=0.5, rel=5, amp=1, pan=0, mix=0.5, room=0.5, damp=0.5;
	var sig, ovr1, ovr2, ovr3, ovr4, env;
	sig = SinOsc.ar(freq, mul:0.5);
	ovr1 = SinOsc.ar(freq * 2, 0, 0.2);
	ovr2 = SinOsc.ar(freq * 3/2, 0, 0.2);
	ovr3 = SinOsc.ar(freq * 81/64, 0, 0.1);
	ovr4 = SinOsc.ar(freq * 32/27, 0, 0.1);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig + ovr1 + ovr2 + ovr3 +ovr4 , pan, amp);
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\overtoneSines);
x.set(\freq, 300);
x.free


x = Synth.new(\reverb, [\in, 7]);
x.set(\mix, 1)
x.set([\mix, 1, \room, 1, \damp, 0]);

~respeaks = [173, 379, 737, 1047, 1337, 2177, 3115];
~resvalleys = [231, 421, 604, 951, 1204, 1733, 7570];

(
Pdef(\exprandseq,
	Pbind(
		\instrument, \overtoneSines,
		\dur, Pexprand(0.2, 0.5),
		\freq, Pseq([173, 173*2, 173*(3/5)], 2),
		\atk, Pexprand(0.2, 1),
		\rel, Pexprand(0.1, 2);
)).play;
)

(
Pdef(\cmajorseq,
	Pbind(
		\instrument, \overtoneSines,
		\midinote, Prand([[48, 57], [45, 48] [36, 45], [33, 41], [40, 47], [42, 49]], inf),
		\dur, Pseq([1, 1, 1], inf),
		\atk, Pexprand(0.47, 1),
		\rel, Pexprand(0.2, 2),
		\out, 7;
	)
).play;
)

(
SynthDef.new(\reverb, {
	arg in, mix=0.5, room=0.8, damp=0.2, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, mix, room, damp)!2;
	Out.ar(out, sig);
}).add;
)

s.reboot