(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\reverb, {
	arg in, mix=0.5, room=0.5, damp=0.5, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

FreeVerb.ar(sig, mix, room, damp)

~x = Synth.new(\blip)
x.free
y = Synth.new(\reverb)
y.set(\in, ~x)