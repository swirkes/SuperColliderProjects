
s.boot;

~p_high = Array.new;


~folder_high = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/piano_high/");

(
~folder_high.entries.do({
	arg path;
	~p_high = ~p_high.add(Buffer.read(s, path.fullPath));
});
);

~p_med = Array.new;


~folder_med = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/piano_med/");

(
~folder_med.entries.do({
	arg path;
	~p_med = ~p_med.add(Buffer.read(s, path.fullPath));
});
);

~birds = Array.new;
~guitar = Array.new;
~neo_rheo = Array.new;
~glock = Array.new;

~folder_birds = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/forest_birds/");
~folder_guitar = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/bowed_guitar/");
~folder_neo_rheo = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/neo_rheo/");
~folder_glock = PathName.new("/Users/swirkes/Documents/SuperColliderProjects/ambient_study_one/samples/glock/");

(
~folder_birds.entries.do({
	arg path;
	~birds = ~birds.add(Buffer.read(s, path.fullPath));
});
~folder_guitar.entries.do({
	arg path;
	~guitar = ~guitar.add(Buffer.read(s, path.fullPath));
});
~folder_neo_rheo.entries.do({
	arg path;
	~neo_rheo = ~neo_rheo.add(Buffer.read(s, path.fullPath));
});
~folder_glock.entries.do({
	arg path;
	~glock = ~glock.add(Buffer.read(s, path.fullPath));
});
)



(
~xpan=0.00;
SynthDef.new(\twobufrdphasor, {
	arg amp=1, out=0, xfade=0, buf1, buf2, start1, start2, end1, end2, rate=1, xpan=1;
	var sig1, sig2, ptr1, ptr2;
	ptr1 = Phasor.ar(0, BufRateScale.kr(buf1)*rate, start1, end1);
	ptr2 = Phasor.ar(0, BufRateScale.kr(buf2)*rate, start2, end2);
	sig1 = BufRd.ar(2, buf1, ptr1);
	sig2 = BufRd.ar(2, buf2, ptr2);
	sig1 = sig1 * amp;
	sig2 = sig2 * amp;
	Out.ar(out, Pan2.ar(XFade2.ar(sig1, sig2, xfade), xpan));
}).add;

SynthDef.new(\bufrd, {
	arg amp=1, out=0, buf, xpan = -1;
	var sig, ptr;
	ptr = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar([0, 1], Pan2.ar(sig, xpan));
}).add;
)
(
~y = Synth.new(\twobufrdphasor, [\buf1, ~guitar[0].bufnum, \start1, 0, \end1, ~guitar[0].numFrames-1, \buf2, ~neo_rheo[0].bufnum, \start2, 0, \end2, ~neo_rheo[0].numFrames-1, \xfade, -0.65]);

(
~p = Pbind(\instrument, \bufrd,
	#[\buf,\dur], Pxrand([
		[~p_high[0].bufnum,~p_high[0].duration],
		[~p_high[1].bufnum,~p_high[1].duration],
		[~p_high[2].bufnum,~p_high[2].duration],
		[~p_high[3].bufnum,~p_high[3].duration],
		[~p_high[4].bufnum,~p_high[4].duration],
		[~p_high[5].bufnum,~p_high[5].duration],
		[~p_high[6].bufnum,~p_high[6].duration],
		[~p_high[7].bufnum,~p_high[7].duration],
		[~p_high[8].bufnum,~p_high[8].duration],
		[~p_med[0].bufnum,~p_med[0].duration],
		[~p_med[1].bufnum,~p_med[1].duration],
		[~p_med[2].bufnum,~p_med[2].duration],
		[~p_med[3].bufnum,~p_med[3].duration],
		[~p_med[4].bufnum,~p_med[4].duration],
		[~p_med[5].bufnum,~p_med[5].duration],
		[~p_med[6].bufnum,~p_med[6].duration],
		[~p_med[7].bufnum,~p_med[7].duration],
		[~p_med[8].bufnum,~p_med[8].duration]
], inf), \amp, 0.3, \xpan, -1,
).play;
)


)



~guitar[0].numFrames-1
~birds[1].numFrames-1
~p.play

~xpan = -1;
~p.set(\xpan, -1);
~y.set(\xpan, -1);

s.scope
s.meter