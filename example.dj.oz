local 
    FirstPart = [duration(seconds:4.0 b2 c3 c#5 a2 [g3 g2 a2] transpose(semitones:~2 [c#4 c3 c]) stretch(factor:0.5 [d5 d3 d2]))]
    SecondPart = [drone(note:[a3 a5 c4] amount:3)]
    Partition = {Flatten [FirstPart SecondPart]}
in
    [partition(Partition) wave('animals/wolf.wav')]
end