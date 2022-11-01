(
s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 8; // set to correct number of clients
s.reboot;
)

s.serverRunning

{.SinOsc.ar(440,mul:0.2)}.play

~valR
~valA