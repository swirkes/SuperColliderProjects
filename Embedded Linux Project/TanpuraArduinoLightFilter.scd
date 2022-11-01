s.boot;

SerialPort.devices;
~port = SerialPort.new("/dev/tty.usbmodem1422401", 115200);
~port.read
~port.close

(
~sapaC = Buffer.read(s,
	"/Users/shanewirkes/Music/SuperCollider/Tanpura/Tanpura C 131Hz SaPa P5.wav");
)

~sapaC.play;

//BUFFER NUMBERS (bufnums)
~sapaC.query;


(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
		});
	}.loop
}).play;
)

(
SynthDef.new(\tanpura, {
	arg out=0, amp=0.5, lpf_freq=200;
	var sig, lpf;
	sig = LPF.ar(PlayBuf.ar(2, 0), lpf_freq);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

~tanpura = Synth.new(\tanpura, [\lpf_freq, ~val.linexp(0, 1023, 80, 4000)]);

(
~control = Routine.new( {
	{
		~tanpura.set(\lpf_freq, ~val.linexp(0, 1023, 80, 4000));
		0.01.wait;
	}.loop;
}).play;
)

