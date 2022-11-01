
s.scope;
s.meter
~copper_pot_freqs = CSVFileReader.readInterpret(Platform.resourceDir +/+ "copper_freqs.csv", true).postcs;

(
SynthDef.new(\fm_copper_synth, {
	arg carHz=500, modHz=100, modAmp=200, del=0.2,
	atk=0.01, rel=1, amp=0.2, pan=0;
	var car, car1, car2, mod1, mod2, env;

	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);

	mod1 = SinOsc.ar(modHz, mul:modAmp);
	mod2 = SinOsc.ar(carHz, mul:modAmp);

	car1 = SinOsc.ar(carHz + mod1) * env * (amp);
	car2 = DelayL.ar((SinOsc.ar(modHz + mod2) * env * (amp)), 0.2, del);

	//car = Pan2.ar(car, pan);
	[Out.ar(3, car1), Out.ar(5, car2)];
	//Out.ar(2, car1);
	}).add;

~copper_pattern = Pbind(
	\instrument, \fm,
	\dur, Pexprand(1/64, 2, inf),
	\carHz, 1871,
	\modHz, Pxrand(~copper_pot_freqs, inf),
	\modAmp, Pwhite(2500, 10000),
	\amp, Pexprand(0.015, 0.15),
	\atk, Pexprand(0.0001, 0.005),
	\rel, Pexprand(0.5, 2.2),
	\del, Pexprand(0.001, 1.0),
	\type, Pwrand([\note, \rest], [0.8, 0.2], inf)
).play;
)
~copper_pattern.stop;

Pgeom(0.1, Pbrown(0.92, 1.02, 0.75, inf), 15).asStream.all;
Pbrown(0.0, 1.0, 0.125, 5).asStream.all
Pexprand(1/64, 2, 10).asStream.all;

p.next;
~glass = Buffer.read(s, "/usr/share/SuperCollider/sounds/bowedGlassMaster.wav");
~book = Buffer.read(s, "/usr/share/SuperCollider/sounds/bookpages.aif");
(
SynthDef.new(\bufrd_noise, {
	arg amp=1, out=0, buf, start=0, end, freq=1;
	var sig, ptr;
	ptr = LFDNoise1.ar(freq).range(start, end);
	sig = BufRd.ar(1, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\bufrd_sine, {
	arg amp=1, out=0, buf, start=0, end, freq=1, mix=0.5, room=0.3, damp=0.5;
	var sig, ptr;
	ptr = SinOscFB.ar(freq, 0.01).range(start, end);
	sig = BufRd.ar(1, buf, ptr);
	sig = sig * amp;
	Out.ar(out, FreeVerb.ar(sig, mix, room, damp));
}).add;
)

~glassSynth = Synth.new(\bufrd_sine, [\out, 0, \buf, ~glass.bufnum, \start, 0, \end, ~glass.numFrames - 1, \freq, 0.002]);

~bookSynth = Synth.new(\bufrd_noise, [\out, 1, \buf, ~book.bufnum, \start, 0, \end, ~book.numFrames - 1, \freq, 1, \amp, 1.5]);

~glassSynth.set(\freq, 0.05);
~glassSynth.free;
~bookSynth.set(\freq, 0.12);
~bookSynth.free
x.free;
~glass.play;
(
q = Pbind(
	\instrument, \bufrd_noise,
	\buf, ~b.bufnum,
	\start, 0,
	\end, ~b.numFrames - 1,
	\freq, 1,
	\dur, 1/8
).play;
)
q.stop;

(
SynthDef.new(\table_top, {
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
	Out.ar(2, sig);
}).add;
)

(
h = Pdef(\table_top, Pbind(
	        //\midinote, Pexprand(20, 127, inf) * 25,
	        \degree, Pwhite(0, 32, inf),
	        \scale, Scale.phrygian(\pythagorean),
			\amp, Pexprand(0.15, 0.25, inf),
	        \dur, Pexprand(0.2, 1, inf))
);
)
h.play














