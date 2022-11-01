s.scope
FreqScope.new
s.freeAll
Server.default.options.outDevice_("Komplete Audio 6");
{SinOsc.ar(MouseY.kr(200, 5000, 1).poll + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul:LFNoise0.kr(8).range(20, 5000)))*0.2!2}.play

(
SynthDef.new(\FMMODD, { |out|
	var mainOsc, carrierOsc, sig;
	mainOsc = SinOsc.ar(MouseY.kr(200, 5000, 1)).poll;
		carrierOsc = SinOsc.ar(MouseX.kr(1, 2000, 1)).poll;
			sig = (mainOsc + carrierOsc) * LFNoise0.kr(8).range(20, 50000) * 0.2;
	Out.ar(out, 0);}).add;

)

x = Synth(\FMMODD)

(
SynthDef.new(\fm, {
	arg carHz=500, modHz=100, modAmp=200,
	atk=0.01, rel=1, amp=0.2, pan=0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carHz + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)
(
p = Pbind(
	\instrument, \fm,
	\dur, 1/8,
	\carHz, Pexprand(20, 10000),
	\modHz, Pexprand(20, 10000),
	\modAmp, Pwhite(0, 10000),
	\amp, Pexprand(0.1, 0.5),
	\atk, Pexprand(0.001, 0.5),
	\rel, Pexprand(0.05, 1.2),
	\pan, Pwhite(-1.0, 1.0)
).play;
)

(
SynthDef.new(\fm2, {
	arg freq=300, mRatio=1, cRatio=1, modAmp=200,
	atk=0.01, rel=1, amp=0.2, pan=0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:modAmp);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

Synth(\fm2)
Synth(\fm2).set(\mRatio, 1, \cRatio, 1)


{PMOsc.ar(300, MouseY.kr(0, 800), MouseX.kr(0, 100)) * 0.2!2}.play

(
SynthDef.new(\drone, {
	arg freq=130, mRatio=1, cRatio=1, modAmp=0.3,
	atkA=0.00185, susA=0.00, relA=2.49, ampA=0.20,
	atkB=0.00211, susB=0.25, relB=51.60, ampB=0.16,
	atkC=0.0487, susC=0.50, relC=20.55, ampC=0.15,
	atkD=0.0725, susD=0.50, relD=60.00, ampD=0.10, pan=0;
	var carSum, carA, carB, carC, envA, envB, envC, envD, mod;
	envA = EnvGen.kr(Env.perc(atkA, relA), doneAction:2);
	envB = EnvGen.kr(Env.perc(atkB, relB), doneAction:2);
	envC = EnvGen.kr(Env.perc(atkC, relC), doneAction:2);
	envD = EnvGen.kr(Env.perc(atkD, relD), doneAction:2);
	mod = SinOsc.ar((freq * 3) * mRatio, mul:modAmp);
	carA = (SinOsc.ar(freq * cRatio + mod) * envA * ampA);
	carB = (Saw.ar(freq * cRatio + mod) * envB * ampB);
	carC = (SinOsc.ar((freq * 9.23) * cRatio + mod) * envC * ampC);
	carSum = carA + carB + carC;
	carSum = Pan2.ar(carSum, pan);
	Out.ar(0, carSum);
}).add;
)

Synth(\drone)


(
SynthDef.new(\additive, {
	arg freq=130,
	atkA=0.00185, decA=0.00163, susA=0.dbamp,
	relA=2.49, pkA=(-3.4.dbamp), ampA=0.20,
	atkB=0.00211, decB=2.17, susB=(-40.dbamp),
	relB=51.60, pkB=(-10).dbamp, ampB=0.06,
	atkC=0.0487, decC=0.0446, susC=(-22.dbamp),
	relC=20.55, pkC=(-10).dbamp, ampC=0.05, gate=0;
	var sig, envA, envB, envC, wavA, wavB, wavC;
	envA = EnvGen.kr(Env.adsr(atkA, decA, susA, relA, curve:\lin), gate);
	envB = EnvGen.kr(Env.adsr(atkB, decB, susB, relB, curve:\lin), gate);
	envC = EnvGen.kr(Env.adsr(atkC, decC, susC, relC, curve:\lin), gate);
	wavA = SinOsc.ar(freq, mul:0.3) * envA;
	wavB = RLPF.ar((Saw.ar(freq, 0.15) * envB), freq * 6, 1);
	wavC = SinOsc.ar((freq * 9.23), mul:0.05) * envC;
	sig =  wavA + wavB + wavC;
	Out.ar(0, sig);
}).add;
)

SynthDef.new(\mod, {
	arg freq, atk=0.00185, dec=0.00163, sus=0.dbamp,
	rel=2.49, amp=0.2;



x = Synth(\additive);
	x.set(\gate, 1);
{PMOsc.ar(Synth(\additive), 793, 12, 0.0, 0.5, 1)}.play

(
{
	var wavA, envA, atkA=0.00185, susA=0.5, relA=2.49;
	envA = EnvGen.kr(Env.asr(atkA, susA, relA, -4.0), doneAction:2);
	wavA = SinOsc.ar(130, mul:0.3) * envA;

}.play;
)

Env.adsr(0.00185, 0.00163, 0.dbamp, 2.49, -3.4.dbamp.plot;

{Pulse.ar(freq: 440.0, width: 0.5, mul: 1.0, add: 0.0)}.play

