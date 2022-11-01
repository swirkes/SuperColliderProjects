(
var synth;
var freq = 220;
var change_freq;
var window;
var button1, button2, button3;

synth = {|freq = 220| LFTri.ar([freq, freq * 2.01], 0, 0.1) }.play;

change_freq = {
	freq = freq * [0.9, 0.9.reciprocal].choose;
	synth.set(\freq, freq);

};

window = Window("Buttons Archaic", Rect(400, 400, 340, 120));

button1 = Button(window, Rect(10, 10, 100, 100));
button1.states = [["I"]];
button1.action = change_freq;

button2 = Button(window, Rect(120, 10, 100, 100));
button2.states = [["III"]];
button2.action = {
	{3.do {change_freq.value; 0.4.wait } }.fork;
};

button3 = Button(window, Rect(230, 10, 100, 100));
button3.states = [["III"]];
button3.action = {
	{8 do: {change_freq.value; 0.1.wait } }.fork;
};

[button1, button2, button3] do: _.font_(Font("Times", 32));
window.onClose = {synth.free};
window.front;
)