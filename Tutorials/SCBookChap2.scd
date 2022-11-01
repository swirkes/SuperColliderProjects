(
({
	var sines=14, speed=20;
	Mix.fill(sines,
		{arg x;
			Pan2.ar(
				SinOsc.ar(x+1*100,
				mul:max(0,
					LFNoise1.kr(speed) +
					Line.kr(1, -1, 30)
				)
), rand2(1.0))})/sines}).play;
)
exprand(1, 100)

thisThread.randSeed = 666; {rand(10.0)} ! 10;
dup("echo", 20)
round([3.141, 5.984, 453.342], 0.01)
sort(round(dup({exprand(1,10)}, 100), 0.1))

s.scope
(
{
	CombN.ar(
		SinOsc.ar(
			midicps(
				LFNoise1.ar(3, 24,
					LFSaw.ar([5, 5.123], 0, 3, 80)
				)
			),
			0, 0.4),
		1, 0.3, 2)
}.play;
)



(
{

	FreeVerb.ar(
		CombN.ar(
			Blip.ar(
				TRand.kr(// frequency or VCO
					100, 500, //range
					Impulse.kr(Line.kr(1, 20, 16))),//trigger
				[TRand.kr( //number of harmonics of VCF
					1, 80, //range
					Impulse.kr(Line.kr(1,20, 16))),
				TRand.kr( //number of harmonics of VCF
					1, 24, //range
					Impulse.kr(Line.kr(1,20,16)))],//trigger
				Linen.kr( //mul, or amplitude, VCA
					Impulse.kr(Line.kr(1, 20, 16)), //trigger
					0, //attack
					0.5, //sustain
					1/Line.kr(1, 20, 16))
	), 0.9, 0.33, 3),  0.5, 0.5, 0.5)
}.play
)

(
p = {
	r = Line.kr(1, 20, 60); //rate
	r = LFTri.kr(1/10) * 3 + 7;
	t = Impulse.kr(r);
	t = Dust.kr(r);
	e = Linen.kr(t, 0, 0.5, 1/r); //envelope uses r and t
	f = TRand.kr(1, 10, t);
	f = e + 1 * 4;
	Blip.ar([f*100, f*200], f, e)
}.play;
)

(
{
	// carrier and modulator not linked
	r = Impulse.kr(10);
	c = TRand.kr(100, 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar(c, m, 12)*0.3
}.play
)

(
{
	var rate=4, carrier=4, modRatio, env;
	carrier = LFNoise0.kr(freq:rate) * 500 + 700; //200 - 1200 Hz Range
	modRatio = MouseX.kr(minval:1, maxval:2.0);
	env = EnvGen.kr(Env.adsr(1/rate, 0));
	PMOsc.ar(carfreq:[carrier, carrier+7], modfreq:carrier*modRatio,
		pmindex:Line.kr(start:1, end:12, dur:6), mul:env)
}.play
)

(
SynthDef(\PMCrotales, {
	arg midi=50, tone=3, art=1, amp=0.8, pan=0;
	var env, out, mod, freq;

	freq = midi.midicps;
	env = Env.perc(0, art);
	mod = 5 + (1/IRand(2, 6));

	out = PMOsc.ar(freq, freq*mod,
		pmindex: EnvGen.kr(env, levelScale: tone, timeScale: art),
		mul: EnvGen.kr(env, levelScale: 0.3, timeScale: art));

	out = Pan2.ar(out, pan);

	out = out * EnvGen.kr(env, levelScale:Rand(0.1, 0.5),
		timeScale:1.3*art, doneAction:2);
	Out.ar(0, out); //Out.ar(bus, out);
}).add;
)

Synth(\PMCrotales, [\midi, rrand(48, 72).round(1), \tone, rrand(1, 6)])




