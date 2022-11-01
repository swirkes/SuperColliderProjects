//some code requires "week10_touchosc_demo.touchosc" interface loaded onto mobile device

//"debug mode" - post all incoming OSC messages
OSCFunc.trace(true);
OSCFunc.trace(false);

//sclang listens for OSC messages on port 57120 by default
NetAddr.langPort; //confirm receiving port

//create an instance of NetAddr for sending OSC to TouchOSC
~touchosc = NetAddr.new("10.194.20.179", 9000);

(
OSCdef.new(\listener, {
	arg msg;
	msg.postln;
	//code that does the thing we want to happen goes here
}, '/1/fader5', nil, 57120);
)

s.boot;

(
SynthDef.new(\tone, {
	var sig, env;
	env = Env.adsr.kr(0, \gate.kr(0));
	sig = LFTri.ar(\freq.kr(300));
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth.new(\tone, [\gate, 1]);
x.set(\gate, 0);

(
x = Synth.new(\tone, [\gate, 0]);

OSCdef.new(\listener, {
	arg msg;
	x.set(\gate, msg[1]);
}, '/1/push1', nil, 57120);
)

(
~scale = [0,12,24,36,48].collect({
	arg n;
	n + 35 + Scale.minorPentatonic.degrees
}).flatten;

~synths = ~scale.collect({
	arg note;
	Synth(\tone, [\freq, note.midicps]);
});

(1..5).do({
	arg row;
	(1..5).do({
		arg col;
		var index = (row-1) * 5 + (col-1);
		OSCdef.new(("multi"++row++col).asSymbol, {
			arg msg;
			~synths.at(index).set(\gate, msg[1])
		}, "/1/multipush1/" ++ row ++ "/" ++ col, nil, 57120);
	});
});
)

s.defaultGroup.set(\gate, 0);

OSCdef.freeAll;
OSCFunc.trace(false);

//sending OSC messages to TouchOSC
~touchosc.sendMsg('/1/fader4', rrand(0.0,1.0))