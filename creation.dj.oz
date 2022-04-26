%Gravity Falls Opening Them by Brad Breeck (arr. ThePandaTooth, rev. Bryce Pointdexter)
local
    FirstLine = [duration(seconds:8 [[f5 d3 d2] [d5 d3 d2] [a4 d3 d2] [d5 d3 d2] [f5 d3 d2] [d5 d3 d2] [a4 d3 d2] [d5 d3 d2]
                                      [f5 f3 f2] [c5 f3 f2] [a4 f3 f2] [c5 f3 f2] [f5 f3 f2] [c5 f3 f2] [a4 f3 f2] [c5 f3 f2]
                                      [e5 a3 a2] [c#5 a3 a2] [a4 a3 a2] [c#5 a3 a2] [e5 a3 a2] [c#5 a3 a2] [a4 a3 a2] [c#5 a3 a2]
                                      [e5 a3 a2] [c#5 a3 a2] [a4 a3 a2] [c#5 a3 a2] stretch(factor:2.0 [[e5 a3 a2] [a5 a3 a2]])
    ])]
    SecondLine = [duration(seconds:8 [[d5 d4 d2] [d5 d4 a2] [d5 d4 d2] [d5 d4 a2] [d5 d4 f3] [d5 d4 d2] [e5 e4 a2] [e5 e4 d2]
                                       [f5 a4 f4 d2] [f5 a4 f4 a2] [f5 a4 f4 f3] [f5 a4 f4 a2] [f5 a4 f4 f3] [f5 a4 f4 d3] [f5 a4 f4 a3] [f5 a4 f4 d3]
                                       [a5 c5 a4 f2] [a5 c5 a4 c3] [a5 c5 a4 f3] [g5 g4 c3] [g5 g4 a3] [g5 g4 f3] [a5 a4 c3] [a5 a4 f3]
                                       [c5 c4 f2] [c5 c4 c3] [c5 c4 f3] [c5 c4 c3] [c5 c4 a3] [c5 c4 f3] [c5 c4 c3] [c5 c4 f3]
    ])]
    ThirdLine = [duration(seconds:8 [[d5 d4 a#2] [d5 d4 f3] [d5 d4 a#3] [d5 d4 f3] d4 a#3 [e5 e4 f3] [e5 e4 a#3]
                                     [f5 f4 a#2] [f5 f4 f3] [f5 f4 a#3] [f5 f4 f3] [e5 d4] [e5 a#3] [e5 f3] [e5 a#3]
                                     [g5 c5 g4 c3] [g5 c5 g4 g3] [g5 c5 g4 c4] [g5 c5 g4 g3] [a5 a4 e4] [a5 a4 c4] [a5 a4 g3] [a5 a4 c3]
                                     [g5 g4 c3] [g5 g4 e3] [g5 g4 a3] [g5 g4 e3] [f5 f4 c#4] [f5 f4 a3] [f5 f4 e3] [f5 f4 f3]
    ])]
    Partition = [transpose(semitones:12 {Flatten [FirstLine SecondLine ThirdLine]})]
in
    [partition(Partition)]
end