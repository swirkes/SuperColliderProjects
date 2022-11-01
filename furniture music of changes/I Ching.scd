~yin = "=== ===";
~yang = "=======";
~changing_yin = "===x===";
~changing_yang = "=======";
(
~cast = 6.do({
	~coin = 2.rand;
	~coin = ~coin + 2.rand;
	~coin = ~coin + 2.rand;
	switch (~coin)
	{0} { ~yin.postln; }
	{1} { ~yang.postln; }
	{2} { ~changing_yin.postln; }
	{3} { ~changing_yang.postln; }
});
)

~cast