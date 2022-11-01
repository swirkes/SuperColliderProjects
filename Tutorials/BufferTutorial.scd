s.boot;
Platform.resourceDir

SerialPort.devices;
~port = SerialPort.new("/dev/tty.usbmodem1422401", 115200);
~port.read
~port.close

(
~sapaC = Buffer.read(s,
	"/Users/shanewirkes/Music/SuperCollider/Tanpura/Tanpura C 131Hz SaPa P5.wav");
~samaC = Buffer.read(s,
	"/Users/shanewirkes/Music/SuperCollider/Tanpura/Tanpura C 131Hz SaMa P4.wav");
~sapaG = Buffer.read(s,
	"/Users/shanewirkes/Music/SuperCollider/Tanpura/Tanpura G 93Hz SaMa P5.wav");
)

~sapaC.play;
~samaC.play;
~sapaG.play;

//FRAMES
~sapaC.numFrames;

//CHANNELS
~sapaC.numChannels;

/* numSamples = numFrames * numChannels */

//DURATION
~sapaC.duration;

//BUFFER NUMBERS (bufnums)
~sapaC.bufnum;
~samaC.bufnum;

//BUFFER SAMPLE RATE
~sapaC.sampleRate;
s.sampleRate;

//SUMMARY
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


{ LPF.ar(PlayBuf.ar(2, 0), EnvGen.kr(Env.new([200, 2000, 200], [20,20], 'lin'))) }.play;

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

