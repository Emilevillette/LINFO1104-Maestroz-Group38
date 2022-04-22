% Ode To Joy
local
   Tune = [transpose(semitones:~1 [c c c]) stretch(factor:3 [c c c [c c#5 c]]) duration(seconds:6 [b c5 d8 [d#3 e f]]) drone(amount:4 [g#5]) b b c5 d5 d5 c5 b a g g a b]
   End1 = [stretch(factor:1.5 [b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]
   End2 = [stretch(factor:1.5 [a]) stretch(factor:0.5 [g]) stretch(factor:2.0 [g])]
   Interlude = [a a b g a stretch(factor:0.5 [b c5])
                    b g a stretch(factor:0.5 [b c5])
                b a g a stretch(factor:2.0 [d]) ]

   % This is not a music.
   Partition = {Flatten [Tune End1 Tune End2 Interlude Tune End2]}
in
   % This is a music :)
   [partition(Partition)]
end