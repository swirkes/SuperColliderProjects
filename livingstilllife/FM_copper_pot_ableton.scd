s.boot;
// Communicate with the server
s.plotTree; // show all active nodes
s.freeAll;  // free all nodes
FreqScope.new(400,200,0,server:s);

     //-----------------------------------------------------------------------//
    //  2-channel fm synth uses highest resonant frequency                   //
   //   as carrier freq and list of 20 000 next highest freqs               //
  //    for modulation frequency. This is flipped for channel 2.           //
 //     pattern uses random values for duration, amplitude and envelope.  //
//-----------------------------------------------------------------------//
(
~copper_pot_freqs = CSVFileReader.readInterpret(Platform.resourceDir +/+ "copper_freqs.csv", true).flatten.select(_!=0).postcs;
~copper_sorted = SortedList(7244);
~copper_sorted.addAll(~copper_pot_freqs);
~copper_sorted.sort.reverse;


SynthDef.new(\fm_copper_synth, {
	arg carHz=500, modHz=100, modAmp=200, del=0.2, mt=0.1,
	amp=0.2, amp2=0.75, pan=0;
	var car, car1, car2, mod1, mod2, env;

	env = Env(
		[0,1,1,0],
		[\atk.ir(0.001), \sus.ir(0.0), \rel.ir(0.2)],
		[\atkcrv.ir(1), 0, \relcrv.ir(-2)]
	).kr(2);

	mod1 = SinOsc.ar(modHz, mul:modAmp);
	mod2 = SinOsc.ar(carHz, mul:modAmp);

	car1 = SinOsc.ar(((carHz * \freqdev.kr(0).midiratio) + mod1)) * env * (amp);
	car2 = DelayL.ar((SinOsc.ar(((modHz * \freqdev.kr(0).midiratio) + mod2)) * env * (amp2)), 0.2, del);

	//car = Pan2.ar(car, pan);
	[Out.ar(0, car1), Out.ar(1, car2)];
	//Out.ar(5, car2);
	}).add;

~copper_pattern = Pbind(
	\instrument, \fm_copper_synth,
	\mt, Pxrand(~copper_sorted, inf),
	\amp, Pexprand(0.001, 0.061),
	\amp2, Pexprand(0.001, 0.061),
	\carHz, Prand([1, 16/15, 10/9, 9/8, 6/5, 5/4, 4/3,
		3/2, 8/5, 5/3, 16/19, 9/5, 15/8], inf) * 1871,
	\modHz, Pkey(\mt) + [0.6, 0.01],
	\dur, Pgbrown(0.001, 1, 0.125, inf),//Pexprand(0.02, 1),
	\modAmp, Pkey(\mt), //Pwhite(2500, 10000),
	\atk, Pexprand(0.0001, 0.005),
	\rel, Pexprand(0.5, 2.2),
	\del, Pexprand(0.001, 0.01),
	\harmonic, Pexprand(1,40).round(1),
	\freqdev, Pwhite(-0.2, 0.2),
	\type, Pwrand([\note, \rest], [0.30, 0.70], inf),
);
)

~copper_pattern_player = ~copper_pattern.play;
~copper_pattern_player.stop;
~copper_pot_freqs[0]*0.0001.postln;
(20..20000).lincurve(1,20, 1, 20000, -4).plot;


(
// Alternative syntax, using a key/pattern array:
~test = Pbind(*[
    instrument:            \fm_copper_synth,
    nharms:                Pseq([4, 10, 40], inf),
    dur:                Pseq(~copper_pot_freqs/1000, inf),
    #[freq, sustain]:    Ptuple([
                            Pseq( (1..16) * 50, 4),
                            Pseq([1/10, 0.5, 1, 2], inf)
                        ])
]).play;
)

~copper_sorted_array = Array.newFrom(~copper_sorted);
~copper_sorted_array.plot("copper", discrete:true);

SynthDef.new(\sineTest, {
	var sig, env;
	sig = SinOscFB.ar(\freq.kr(440) * \freqdev.kr(0).midiratio,fdbk,mul:0.5);
	env = Env(
		[0,1,1,0],
		[\atk.ir(0.001), \sus.ir(0.0), \rel.ir(0.2)],
		[\atkcrv.ir(1), 0, \relcrv.ir(-2)]
	).kr(2);
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;

~sine_pattern = Pbind(
	\instrument, \sineTest,
	\mt, Pxrand(~copper_sorted, inf),
	\fdbk, Pexprand(0.5pi, 2pi) * 0.1,
	\amp, Pexprand(0.001, 0.061),
	\freq, Pxrand([1, 16/15, 10/9, 9/8, 6/5, 5/4, 4/3,
		3/2, 8/5, 5/3, 16/19, 9/5, 15/8], inf) * 1871,
	\dur, Pkey(\mt) * 0.00001,
	\atk, Pexprand(0.0001, 0.005),
	\rls, Pexprand(0.5, 2.2),
	\type, Pwrand([\note, \rest], [0.30, 0.70], inf),
);

~pat = Pbind(
	\instrument, \sineTest,
	\dur, Pexprand(0.02, 1),
	\atk, Pexprand(0.5,2),
	\sus, 0,
	\rel, 4,
	\relcrv, -2,
	\freqdev, Pwhite(-0.2, 0.2),
	\midinote, 40,
	\harmonic, Pexprand(1,40).round(1),
	\amp, 0.04,
	);

~pat.play;
~sine_pattern.stop;
(
//Using Pmono to change one synth instead of multiple...avoid overloading the system
~copper_mono = Pmono(
	\fm_copper_synth,
	\mt, Pxrand(~copper_sorted, inf),
	\amp, Pexprand(0.001, 0.061),
	\amp2, Pexprand(0.001, 0.061),
	\carHz, Prand([1, 16/15, 10/9, 9/8, 6/5, 5/4, 4/3,
		3/2, 8/5, 5/3, 16/19, 9/5, 15/8], inf) * 1871,
	\modHz, Pkey(\mt) + [0.6, 0.01],
	\dur, Pgbrown(0.001, 1, 0.125, inf),//Pexprand(0.02, 1),
	\modAmp, Pkey(\mt), //Pwhite(2500, 10000),
	\atk, Pexprand(0.0001, 0.005),
	\rel, Pexprand(0.5, 2.2),
	\del, Pexprand(0.001, 0.01),
	\harmonic, Pexprand(1,40).round(1),
	\freqdev, Pwhite(-0.2, 0.2),
	\type, Pwrand([\note, \rest], [0.30, 0.70], inf),
);
)
~copper_mono_player = ~copper_mono.play;
~copper_mono_player.stop;


//////////////SET///////////////////////////////
~copper_synth = Synth.new(\fm_copper_synth);

(
~copper_pattern_set = Pbind(
	\type, \set,
	\mt, Pxrand(~copper_sorted, inf),
	\amp, Pexprand(0.001, 0.061),
	\amp2, Pexprand(0.001, 0.061),
	\carHz, Prand([1, 16/15, 10/9, 9/8, 6/5, 5/4, 4/3,
		3/2, 8/5, 5/3, 16/19, 9/5, 15/8], inf) * 1871,
	\modHz, Pkey(\mt) + [0.6, 0.01],
	\dur, Pgbrown(0.001, 1, 0.125, inf),//Pexprand(0.02, 1),
	\modAmp, Pkey(\mt), //Pwhite(2500, 10000),
	\atk, Pexprand(0.0001, 0.005),
	\rel, Pexprand(0.5, 2.2),
	\del, Pexprand(0.001, 0.01),
	\harmonic, Pexprand(1,40).round(1),
	\freqdev, Pwhite(-0.2, 0.2),
);
)
