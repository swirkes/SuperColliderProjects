SerialPort.devices;

~port = SerialPort.new("/dev/tty.usbmodem1A12201", 9600);
~port.close
~port.read;
(
x = [];
30.do{x = x.add(~port.read)};
x = x.collect(_.asAscii);
)
(
~rrr= Routine.new({
	var byte, str, res;
	var idx = 0;
	var key = \a;
	var stopon = \b;
	var tmp = "";
	var inttmp = 0;
	var char = ~port.read; // determine if we're
	                      //expecting an "a" or a "b" result
	{
	if (char == $a) { key = \a; stopon = $b; };
	if (char == $b) { key = \b; stopon = $a; };
	while({byte = ~port.read; byte != stopon}, {
		tmp = tmp ++ byte.asAscii;
	});

	inttmp = tmp.asInteger;
	(key + "equals" + inttmp).postln;

}.loop

}).play;
)
(
~light_CharArray = [ ];
~light_getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~light_charArray = [ ];
		});
	}.loop
}).play;
)

(
SynthDef.new(\saw, {
	arg out, freq=440, cutoff = 1000, env, atk=0.5, rel=1.0;
	var sig;
	sig = Saw.ar([freq, freq+1]);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	//sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\LFO, {
	arg in, out=0, cutoff=1000;
	var sig;
	sig = In.ar(in, 1);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

~a = Synth(\saw);
~a.free
(
~control = Routine.new( {
	{
		x.set(\cutoff, ~val.linexp(0, 1023, 80, 4000));
		0.01.wait;
	}.loop;
}).play;
)

~a.nodeID
~val.next
x = Synth.new(\LFO, [\in, 6]);

(
Pdef(\xx, Pbind(
	\instrument, \saw,
	\id, ~a.nodeID,
	\midinote, Pseq([20, 27, 24, 16] + 20, inf),
	\dur, Pseq([1, 1, 1/2, 1/4, 1/8, 1/5], inf),
	\atk, Pseq([0.1, 0.2, 0.5, 1], inf),
	\rel, Pexprand(0.01, 5),
	\out, 6;
	)).play;
)

f = FuncStream(~val);
f.next



~val;
~port.close;







(
SynthDef.new(\sine, {
	arg freq=200, atk=0.5, rel=5, amp=1, pan=0;
	var sig, ovr1, ovr2, ovr3, ovr4, env;
	sig = SinOsc.ar(freq, mul:0.5);
	ovr1 = SinOsc.ar(freq * 2, 0, 0.2);
	ovr2 = SinOsc.ar(freq * 3/2, 0, 0.2);
	ovr3 = SinOsc.ar(freq * 81/64, 0, 0.1);
	ovr4 = SinOsc.ar(freq * 32/27, 0, 0.1);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig + ovr1 + ovr2 + ovr3 +ovr4 , pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sine);
x.set(\freq, 300);

(
Pdef(\sineseq,
	Pbind(
		\instrument, \sine,
		\dur, Pexprand(0.2, 1),
		\freq, Pexprand(200, 800),
		\atk, Pexprand(0.02, 1),
		\rel, Pexprand(1, 7);
)).play;
)