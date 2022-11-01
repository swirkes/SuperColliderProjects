s.boot;

(
var x=50, y=50, xv=10.neg, yv=15, grav=0.9, bounce=0.7, friction=0.96, color=Color.rand, sound, rev;
r{
	Window.closeAll;

	0.02.wait;

	rev = {In.ar(50,2).blend(LPF.ar(GVerb.ar(In.ar(50,2).sum, 299, 4),1000, 0.5), 0.15)}.play;

	sound = {
		Out.ar(
			50,
			SinOsc.ar(exprand(200,2000) * [1,1.015]) * Env.perc(0.002, 0.3, 0.1, curve:-12).ar(2)
		);
	};

	t = 0;
	w = Window(
		"bouncing ball",
		Rect(100, 100, 400, 400)
	)
	.onClose_({ s.freeAll })
	.alwaysOnTop_(true).front;

	u = UserView(w, w.view.bounds)
	.background_(Color.gray(0.2))
	.keyDownAction_({ |v, char|
		if(char == $ ) {
			x = rrand(10,390);
			y = rrand(5,100);
			xv = exprand(5,35) * [1,-1].choose;
			yv = rrand(10, 20);
			color = Color.rand;
		};
	})
	.drawFunc_({
		Pen.fillColor_(Color.gray(0.0,0.1));
		Pen.fillRect(u.bounds);
		x = x + xv;
		y = y + yv;
		yv = yv + grav;

		if((x > 390) || (x < 10)) {
			x = x.clip(8,392);
			xv = xv.neg;
			xv = xv * friction;
			if(xv.abs > 2) {play(sound, fadeTime:0, outbus:50)};
		};

		if(y > 390) {
			y = 392;
			yv = yv * bounce.neg;
			xv = xv * friction;
			if(yv.abs > 2) {play(sound, fadeTime:0, outbus:50)}
		};

		if(y < 10) {
			y = 8;
			yv = yv.neg;
			play(sound, fadeTime:0, outbus:50);
		};

		if((yv < 0) && (yv > -2)) {yv = 0};

		Pen.fillColor_(color);
		Pen.addArc(x@y, 10, 0, 2pi);
		Pen.fill;

	});
	u.frameRate_(30);
	u.clearOnRefresh_(false);
	u.animate_(true);

	StaticText(w, Rect(0,0,400,40))
	.stringColor_(Color.gray(0.8))
	.string_("press spacebar to reset")
	.align_(\center)
}.play(AppClock);
)
