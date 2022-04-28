local
    FirstPart = [duration(seconds:4.0 1:[b2 c3 c#5 a2 [g3 g2 a2] transpose(semitones:~2 1:[c#4 c3 c]) stretch(factor:0.5 1:[d5 d3 d2])])]
    SecondPart = [drone(note:[a3 a5 c4] amount:3) [g5 e2 nil] silence(duration:2.0) a0 [b1 b2 c4] transpose(semitones:~2 [c#4 c c stretch(factor:2.0 [c d e])])]
    Partition = {Flatten [FirstPart SecondPart]}

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ForWave = 'wave/animals/wolf.wav'

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    PartiOne = [[c2 d1 e2] [a2 b1 g5] b2]
    PartiTwo = [[a5 b2 c3] [g2 b1 g3] a4 g3]
    ForMerge = [0.3#[partition(PartiOne)] 0.5#[partition(PartiTwo)] 0.2#[samples([0.2 0.4 0.1 ~0.2 ~0.9 0.3])]]

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ForRepeat = [duration(seconds:3.0 1:[g5 f#5 b5 e5 d5 g5 b4 e5 a4 d5])]


in
    [partition(Partition) wave(ForWave) merge(ForMerge) repeat(amount:2 1:[partition(ForRepeat)]) loop(seconds:5.0 1:[wave('wave/animals/duck_quack.wav')]) ]
    
end 