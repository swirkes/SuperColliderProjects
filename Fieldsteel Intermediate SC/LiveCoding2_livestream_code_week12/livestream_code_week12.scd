s.boot;

//quick recap of week 11

p = ProxySpace.new(s).push;

~sig.play.fadeTime_(2);

(
~sig = {
	var sig;
	sig = SinOsc.ar({exprand(80,1600)}!16) * 0.1;
	sig = Splay.ar(sig);
};
)

~sig = {};

~sig.stop(fadeTime:1);
~sig.play(fadeTime:1);

~sig.release;
~sig.send;

~sig.clear(3);

//buffers
//this won't work if the current environment is a ProxySpace

~buf = Buffer.read(s, "/Users/eli/Documents/Illinois/Teaching/AY 2020-2021/Spring 2021/MUS 499C/Livestream Code/livestream_code_week12/audio/alm.aiff");

~buf.clear;


//Events are useful for storing any number of named things in any sort of hierarchy
e = ();
e.stuff = 5;
e.things = ();
e.things.numbers = [1, 17, 3.9];
e.things.numbers[1];

(
//e.buf.path = path to audio files
//e.buf[0] = 0th audio file
//e.buf[1] = 1st audio file, etc.

e = ();
e.buf = ();
e.buf.path = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";
PathName(e.buf.path).entries.collect({
	arg n,i;
	e.buf[i] = Buffer.read(s, n.fullPath);
});
)

e.buf[2].play; //testing

//store whatever you like in e — anything you might need to keep track of
e.freq = ();
e.freq[0] = Array.fill(8, {exprand(200,1000)});

//a buffer-driven proxy source:
~sig.clear;

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig);
}
)

~sig.release;

~sig2.play.fadeTime_(3);

(
//doneAction:2 is much less of a concern when using proxies
~sig2 = {
	var sig;
	sig = PlayBuf.ar(1!2, e.buf[4], [1.0,0.9]) * 0.5;
};
)

~sig2.clear;

~sig.send;

//modularity/routing/mapping/interconnecting

~sig.clear;

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.5;
}
)

(
~verb.play.fadeTime_(3);
~verb = {
	var sig;
	sig = GVerb.ar(\in.ar(0), 250, 4);
	sig = LPF.ar(sig, 2000);
	sig = sig * 0.5;
};
)

//may produce a pop
~verb.map(\in, ~sig);
~verb.unmap(\in);

//crossfade mapping
~verb.xmap(\in, ~sig);
~verb.xmap(\in, 0);

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	//On stream I meant to set the default value to 0!2 instead of 0
	sig = CombN.ar(\in.ar(0!2), 1, 0.3, 8);
	sig = sig * 0.5;
};
)

//send to delay
~del.xmap(\in, ~sig);

//remove from delay send
~del.xmap(\in, 0!2);

//remove from reverb send
~verb.map(\in, 0!2);

//effects in series: sig -> del -> reverb
~verb.map(\in, ~del);

(
//remove dry, only reverb wet
~sig.stop(fadeTime:5);
~del.xmap(\in, 0!2);
~verb.xmap(\in, ~sig);
)

//bring dry back into the mix
~sig.play(fadeTime:5);

~lfo = {SinOsc.kr(0.1).exprange(0.05, 0.5)};

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(\in.ar(0), 1, \indeltime.kr(0.3), 8);
	sig = sig * 0.5;
};
)

//modulate delay time
~del.xmap(\indeltime, ~lfo);

~lfo2 = {SinOsc.kr(0.12).exprange(400,5000)};

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.5;
	sig = RLPF.ar(sig, \filt.kr(15000), 0.2);
}
)

//apply resonant lowpass filter to source signal
~sig.xmap(\filt, ~lfo2);

~lfo = {SinOsc.kr(0.1).exprange(0.1, 0.5)};

(
//unmap and fade out
~verb.xmap(\in, 0);
~del.xmap(\in, 0!2);
~sig.clear(3);
)

////////////////////////////////
//an alternative routing approach:
//plug proxy objects directly into other proxy source functions

p.clear;

(
~sig.play.fadeTime_(2);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.25;
}
)

(
~verb.play.fadeTime_(3);
~verb = {
	var sig;
	sig = GVerb.ar(~del.ar(1) + ~sig.ar(1), 250, 9);
	sig = LPF.ar(sig, 1000);
	sig = sig * 0.5;
};
)

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(~sig.ar(2), 1, 0.3, 8);
	sig = sig * 0.5;
};
)

~lfo.clear;
~lfo = {SinOsc.kr(0.1).exprange(0.05,0.8)}

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(~sig.ar(2), 1, ~lfo.kr(1), 8);
	sig = sig * 0.5;
};
)

//side note — you can set volume of proxy monitoring nodes via .vol_(number)
~sig.vol_(1.0);
~del.vol_(1.0);

p.clear(3);

//set & xset

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, detune = \detune.kr(1), bend;
	bend = LFNoise2.kr(0.1!16).bipolar(detune).midiratio;
	sig = Saw.ar(\freq.kr(200) * bend) * 0.1;
	sig = LPF.ar(sig, \cf.kr(2000));
	sig = Splay.ar(sig);
};
)

//instantaneous set
~sig.set(\freq, 450, \detune, 4);

//xfade new version with updated parameters
~sig.xset(\freq, 28.midicps, \detune, 0.2);

(
//with varlagged parameters
~sig.play.fadeTime_(3);
~sig = {
	var sig, detune = \detune.kr(1).varlag(3,1), bend;
	bend = LFNoise2.kr(0.1!16).bipolar(detune).midiratio;
	sig = Saw.ar(\freq.kr(200).varlag(2,1) * bend) * 0.1;
	sig = LPF.ar(sig, \cf.kr(2000));
	sig = Splay.ar(sig);
};
)

//set will interpolate with lag time
~sig.set(\freq, 50, \detune, 0.5);

//xset will ignore lag time
~sig.xset(\freq, 150, \detune, 2);

~sig.clear(6);