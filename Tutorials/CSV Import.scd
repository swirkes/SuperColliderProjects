    // open file, read and put strings into array, close file.
x = CSVFileReader.read("/Users/swirkes/Downloads/copper_pot_freqs_filtered - pot_freqs.csv").postcs;

    // can skip empty lines:
x = CSVFileReader.read("/Users/swirkes/Downloads/copper_pot_freqs_filtered - pot_freqs.csv", true).postcs;

    // can skip blank entries caused by multiple commas:
x = CSVFileReader.read("/Users/swirkes/Downloads/copper_pot_freqs_filtered - pot_freqs.csv", true, true).postcs;

    // do file open/close by hand if you prefer:
f = File("CSVReadTest.sc", "r"); f.isOpen;
t = CSVFileReader(f);
t.read(true, true).postcs;
f.close;

(
// write a test file with numbers:
f = File("CSVReadTestNum.sc", "w");

(1..10).do { |n| f.write(n.asString ++ ","); };
f.close;
)

x = CSVFileReader.read("CSVReadTestNum.sc", true, true).postcs;
x.collect(_.collect(_.interpret));    // convert to numbers.

    // or do it immediately:
~copper_pot_freqs = CSVFileReader.readInterpret("/Users/swirkes/Downloads/copper_pot_freqs_filtered - pot_freqs.csv", true).postcs;

~copper_pot_freqs.at(;

(
// write a test file with several lines of numbers:
f = File("CSVReadTestNum.sc", "w");

(1..100).do { |n|
    f.write(n.asString ++ if (n % 10 != 0, ",", Char.nl)); };
f.close;
)


x = CSVFileReader.readInterpret("CSVReadTestNum.sc", true, true).postln;