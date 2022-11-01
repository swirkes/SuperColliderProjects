(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

u.drawFunc_({
	Pen.strokeColor_(Color.new(0,0.5,1));
	Pen.width_(4);
	Pen.line(100@100, 200@300);
	Pen.stroke;
});
)

(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
	resizable: false,
	border: false
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

u.drawFunc_({
	Pen.strokeColor_(Color.new(0,0.5,1));
	Pen.width_(4);
	Pen.line(rrand(100,400)@100, 200@300);
	Pen.stroke;
});
)

u.animate_(true);
u.frameRate_(10);
u.animate_(false);

(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
	resizable: false,
	border: false
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

u.drawFunc_({
	64.do({
		arg n;
		var x = 60 + (n*6);
		Pen.strokeColor_(Color.new(0,n.linlin(0,63,0.4,0.7),1));
		Pen.width_(4);
		Pen.line(x@300, x@200);
		Pen.stroke;
	});
});
)

(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
	resizable: false,
	border: false
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

u.drawFunc_({
	64.do({
		arg n;
		var t = n.linlin(0,64,0,2pi);
		var x = 60 + (n*6);
		var y = sin(t).linlin(-1,1,250,150);
		Pen.strokeColor_(Color.new(0,n.linlin(0,63,0.4,0.7),1));
		Pen.width_(4);
		Pen.line(x@300, x@y);
		Pen.stroke;
	});
});
)

(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
	resizable: false,
	border: false
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

~count = 0;
u.drawFunc_({
	64.do({
		arg n;
		var t = n.linlin(0,64,0,2pi);
		var x = 60 + (n*6);
		var y = sin(t + ~count).linlin(-1,1,250,150);
		Pen.strokeColor_(Color.new(0,n.linlin(0,63,0.4,0.7),1));
		Pen.width_(4);
		Pen.line(x@300, x@y);
		Pen.stroke;
	});
	~count = ~count + (2pi/64);
});
)

u.animate_(true);
u.frameRate_(20);
u.animate_(false);

s.boot;

(
s.options.numWireBufs_(512);
s.reboot;
)

(
x = {
	var sig, chain;
	sig = PinkNoise.ar(0.5);
	sig = BPF.ar(
		sig,
		SinOsc.kr(0.1, 3pi/2).exprange(200,18000),
		0.2,
		4
	);
	chain = FFT(LocalBuf(128), sig);

	chain = chain.pvcollect(128, {
		arg mag, phs, bin, index;

		//write each magnitude value to a unique control bus
		Out.kr(index, mag);
		[mag, phs]
	}, 1, 64);

	sig = IFFT(chain);
	sig!2;
}.play;
)

(
//access these busses language-side
s.newBusAllocators;
Bus.control(s,1);
b = Bus.control(s, 64);
)

b.getnSynchronous; //retrieve 64 bus values

(
Window.closeAll;
w = Window.new(
	"week13",
	Rect(1400,500,500,500),
	resizable: false,
	border: false
)
.alwaysOnTop_(true)
.front;

u = UserView.new(w, w.view.bounds)
.background_(Color.gray(0.1));

u.drawFunc_({
	64.do({
		arg n;
		var x = 60 + (n*6);
		var y = b.getnSynchronous.at(n) * 40;
		Pen.strokeColor_(Color.new(0,n.linlin(0,63,0.4,0.7),1));
		Pen.width_(4);
		Pen.line(x@300, x@(300-y));
		Pen.stroke;
	});
});
)

u.animate_(true); //animate!

(
u.drawFunc_({
	64.do({
		arg n;
		var x = 60 + (n*6);
		var y = b.getnSynchronous.at(n) * 60;

		//change color
		Pen.strokeColor_(Color.new(1,n.linlin(1,63,0.4,0.7),0));

		//slightly wider bars
		Pen.width_(5);

		Pen.line(x@300, x@(300-y));
		Pen.stroke;
	});
});
)

x.set(\gate, 0, \fadeTime, 2);

(
~path = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";
~buf = Buffer.readChannel(s, ~path++"beat.aiff", channels:[0]);
~buf2 = Buffer.readChannel(s, ~path++"delay.aiff", channels:[0]);
)

(
x = {
	var sig, chain;
	sig = PlayBuf.ar(1, ~buf, BufRateScale.ir(~buf), loop:1);
	chain = FFT(LocalBuf(128), sig);

	chain = chain.pvcollect(128, {
		arg mag, phs, bin, index;
		Out.kr(index, mag);
		[mag, phs]
	}, 1, 64);

	sig = IFFT(chain);
	sig!2;
}.play;
u.animate_(true);
)

(
x.free;
u.animate_(false);
)

(
x = {
	var sig, chain;
	sig = PlayBuf.ar(1, ~buf2, BufRateScale.ir(~buf2), loop:1);
	chain = FFT(LocalBuf(128), sig);

	chain = chain.pvcollect(128, {
		arg mag, phs, bin, index;
		Out.kr(index, mag);
		[mag, phs]
	}, 1, 64);

	sig = IFFT(chain);
	sig!2;
}.play;
u.animate_(true);
)

(
x.free;
u.animate_(false);
)

(
Window.closeAll;
s.quit;
)

//see Pen and UserView help files for more methods and examples