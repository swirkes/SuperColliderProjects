MIDIClient.init;
CmdPeriod.add({ (1..127).do{arg n; m.noteOff(0, n)} });
CmdPeriod.add({ (1..127).do{arg n; m.noteOff(1, n)} });


m = MIDIOut.new(0);
n = MIDIOut.new(0);


m.noteOn(0, 54, 127);

m.noteOff(0, 54, 30);

Routine({
	m.control(0, 14, 2);
}.loop).play



m.noteOn(1, )

(
~steinarray = [[38, 42, 50], [50, 61, 62],[62, 66, 73], [74, 78, 86], [86, 88, 98], [91,98, 103], [103, 107, 115]];

//[F3,C#4,F#4,A4,D5,F#5,C6,E6,F#6,B6,C#7,F7,G7,A7,C8,D8,G8,A8,C9];

~coffee2midi =[[53, 61, 66], [69, 74, 78], [84, 88, 90], [95, 97, 101], [103, 105, 108], [110, 115, 117], 120];

~steinway = Pdef(\pianodes,
	Pseq([
		Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
			\midinote, Pwrand(~coffee2midi, [0.2, 0.5, 0.5, 0.1, 0.5, 0.8, 0.8], inf),
			\amp, Pexprand(0.15, 0.85, inf),
			\sustain, 5,
			\dur, Pexprand(0.55, 2, inf)),
		Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
			\degree, Pwhite(-7, 14, 2),
			\amp, Pexprand(0.15, 0.85, 2),
			\sustain, 5,
			\dur, Pexprand(1.25, 2, inf)),
        Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
			\midinote,
			Pwrand(~coffee2midi + 7, [0.2, 0.5, 0.5, 0.1, 0.5, 0.8, 0.8], inf),
			\amp, Pexprand(0.15, 0.85, 2),
			\sustain, 5,
			\dur, Pexprand(0.5, 2, inf)),
	    Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
			\midinote, Pwrand(~coffee2midi + 24, [0.5, 0.2, 0.8, 0.9, 0.1, 0.1, 0.1], inf),
			\amp, Pexprand(0.15, 0.85, 2),
			\sustain, 5,
			\dur, Pexprand(0.25, 2, inf))], inf)
);
)
(
h = Pdef(\steinray, Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
	        //\midinote, Pexprand(20, 127, inf) * 25,
	        \degree, Pwhite(0, 32, inf),
			\amp, Pexprand(0.15, 0.25, inf),
			\sustain, 0.2,
	        \dur, Pexprand(0.05, 1, inf))
);
)
h.set([\degree, Pwhite(-14, 26, inf)]);
h.play;
h.stop;
~steinway.play;

~steinway.stop;

~satie.p.stop;
s.record;
