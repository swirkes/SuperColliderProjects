(
MIDIClient.init;
CmdPeriod.add({ (1..127).do{arg n; m.noteOff(0, n)} });
CmdPeriod.add({ (1..127).do{arg n; m.noteOff(1, n)} });
m = MIDIOut.new(0);
)


~duchamp = SimpleMIDIFile.read("/Users/averno/Music/SuperColliderProjects/furniture music of changes/duchamp_clip_1.mid");
(
~midiList = List.new();
i = 0;
while ({i < ~duchamp.midiEvents.size },
	{ if(~duchamp.midiEvents[i].at(2) == \noteOn)
		{
		    ~midiList.add(~duchamp.midiEvents[i].at(4));
        };
		i =  i + 1;});
)
~midiArray = ~midiList.asArray

rrand(0, 64).reciprocal

(
Pdef(\duchampSeq,
	Pbind(
		\midinote, Pseq([50, 52, 53], inf),
		\dur, Pwhite(1, 8, inf).reciprocal,
		\amp, 0.5;
)).play;
);


~midiList = List.new;

~duchamp.midiEvents[1].at(2);
~duchamp.size;

~duchamp.init0(120, "5/4");

~duchamp.timeMode = \seconds;

~duchamp.tempoMap;

~duchamp.p.play;
~duchamp.plot;

~duchamp.midiEvents.dopostln; // all midi events
~duchamp.metaEvents.dopostln; // notice the incorrect 'endOfTrack' events for track 1 & 2;

~satie.adjustEndOfTrack;
~satie.metaEvents.dopostln; // try again

~satie.tempoMap; // get the tempo map ( [[ startTime, bpm ], [ etc.. ]] )
~satie.timeSignatures; // get the time signatures ( ( [[ startTime, a/b ], [ etc.. ]] )

~satie.p;// convert to Pattern and play
~satie.write; // now play the file in Quicktime, or open with another app
~satie.plot;  // uses ScaledUserView::
m.noteOn(0, 67, 30);


x = ~satie.generatePatternSeqs
y = x.iter.all(());


Pbind(
			\type, \midi,
			\midicmd, \noteOn,
			\midiout, m,
			\chan, 0,
			\midinote, Pwrand(~steinarray, [0.2, 0.5, 0.5, 0.1, 0.5, 0.8, 0.8], inf),
			\amp, Pexprand(0.15, 0.85, inf),
			\sustain, 5,
			\dur, Pexprand(0.55, 2, inf))

MIDIClient.init;
m = MIDIOut(0);  // Linux users: MIDIOut(0, MIDIClient.destinations[0].uid)

a = Pbind(\degree, Prand([1, 2, 3, [0, 5]], inf), \bend, Pwhite(0, 76, inf));


// chain a midi event into the pattern and play it (see Pchain)

(~satie.p <> (type: \midi, midiout: m)).play;