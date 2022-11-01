(
//here's a synthdef that allows us to play from a buffer, with a fadeout
SynthDef("playbuf", {arg out = 0, buf, gate = 1;
	Out.ar(out,
		PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop:1.0)
		* Linen.kr(gate, doneAction:2);
	)
}).add;
//load all the paths in the sounds/folder into buffers
~someSounds = "/Users/swirkes/Documents/SuperColliderProjects/Samples/Tanpura/*".pathMatch.collect{ |path| Buffer.read(s, path)};
)

~groupOfindivCueFolders = "/Users/swirkes/Documents/SuperColliderProjects/Samples/Tanpura/*"
.pathMatch.collect{ |item|
	(item.asSymbol++"*").pathMatch };

Post << ~groupOfindivCueFolders; //see them all

//check how many cues you will have in the end
~groupOfindivCueFolders.size;

//automate the buffering process for all cues:
~bufferedCues = ~groupOfindivCueFolders.collect{|item, i| item.collect{|path|
	Buffer.read(s, path)}}; //now all of our cue files are sitting in their buffers

~bufferedCues[0]; //here is cue 1

// see it in the post window
Post << ~bufferedCues[0];

//play them all in a Group, using our previous synthdef, we use bind here to ensure they start simultaneously
(
s.bind({
	~nowPlaying = Group.new(s); //a group to put all the channel synths in
	~bufferedCues[0].do({|cue| Synth("playbuf", [buf: cue], ~nowPlaying)})
});
)

//fade them out together by sending a release message to group
~nowPlaying.release;



(
{
	Resonz.ar(Dust2.ar(5), 300, 0.001, 100) +
	Resonz.ar(Dust2.ar(3), 600, 0.001, 100) +
	Resonz.ar(Dust2.ar(2), 900, 0.001, 100) * 3.reciprocal ! 2;
}.play
)

(
f=40;
n=50;
{
	Mix.fill(n, { |i| Resonz.ar(Dust.ar(5), f * (i + 1), 0.001, 100)})
	* n.reciprocal ! 2;
}.play
)
(
(
f=300;
n=30;
t = Array.fill(n, {|i|
	{Resonz.ar(Dust2.ar(5), f * (i + 1), 0.001, 300)
		* n.reciprocal ! 2}.play;
    })
);
(
w = Window.new("Buttons", Rect(50, 100, 290, 250), scroll:true);
w.view.decorator = FlowLayout.new(w.view.bounds);
n.do({|i|
	Button.new(w, Rect(0, 0, 130, 30)).states_([
		["Freq" + (f * (i + 1)) + "On", Color.black, Color.white],
		["Freq" + (f * (i + 1)) + "On", Color.white, Color.black]
	])
	.action_({ arg butt;
		t[i].run(butt.value == 0);
	});
});
w.front;
);
)

(
//select sound files
var file, soundPath;
~buffers = List[];
Dialog.getPaths({arg paths;
	paths.do({|soundPath|
		//post the path to verify that it is the one you expect!
		soundPath.postln;
		//adds the recently selected Buffer to your list
		~buffers.add(Buffer.read(s, soundPath);); })
});
)

~buffers.size;
~buffers[0].play;

(
//buffer player with done action and control of envelope and panning
SynthDef(\samplePlayer, {arg out = 0, buf = 0, rate = 1, at = 0.01,
	rel = 0.1, pos = 0, pSpeed = 0, lev = 0.5;
	var sample, panT, amp, aux;
	sample = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), 1, 0, 0);
	panT = FSinOsc.kr(pSpeed);
	amp = EnvGen.ar(Env.perc(at, rel, lev), doneAction:2);
	Out.ar(out, Pan2.ar(sample, panT, amp));
}).add;
)

Synth(\samplePlayer, [\out, 0, \buf, ~buffers.choose, \rel, 2.9]);

(
~stut = Routine( { var dur, pos;
	~stutPatt = Pseq([Pgeom(0.01, 1.1707, 18), Pn(0.1, 1), Pgeom(0.1, 0.94, 200)]);
~str = ~stutPatt.asStream;
100.do{
	dur = ~str.next;
	dur.postln; //so we can check values on the post window
		~sample = Synth("samplePlayer", [\out, 0, \buf, ~bufferedCues[0], \at, 0.1, \rel, 0.05, \pSpeed, 0.5, \lev, 1]);
	dur.wait;
	}
});
)

~stut.play
~stut.stop





