fun{CountElems Music Acc}
if(Music == nil) then
   0.0
else
   {CountElems Music.2 Acc+1.0}
end
end


fun{MusicLength Music Acc}
{CountElems Music 0.0}/44100.0
end

fun{AddUntil Lst Remaining}
if(Remaining==0.0) then
   nil
else
   Lst.1 | {AddUntil Lst.2 Remaining-1.0}
end
end

fun {Loop Duration Music MusicLength}
if(Duration>0 andthen Duration<MusicLength) then
   {AddUntil Music Duration*44100.0}
else if(Duration>=1) then
   {Append Music {Loop Duration-MusicLength Music MusicLength}}
else
   nil end
end
end


a silence transpose(semitones:~2 [c#4 c c stretch(factor:2.0 [c d e]) silence]) stretch(factor:3.0 [silence c c c [c c#5 c]]) duration(seconds:6 [silence b c5 d8 [d#3 e f]]) drone(amount:4 [g#5]) drone(amount:3 [silence])

fun {PartitionFreq Music P2T}
   fun {PartitionFreqAcc Music P2T Acc}   
      if(Music == nil) then
         {List.reverse Acc}
      else
         case Music.1
         of nil then nil
         [] silence(duration:_) then {PartitionFreqAcc Music.2 P2T {SampleFrequency 0.0 Music.1.duration*44100.0 0.0}|Acc}
         [] _|_ then  {PartitionFreqAcc Music.2 P2T {Merge {PartitionFreqChord Music.1 1.0/{IntToFloat{List.length Music.1}} P2T}}|Acc}
         else
            {PartitionFreqAcc Music.2 P2T {SampleFrequency {Frequency {GetNoteHeight Music.1}} Music.1.duration*44100.0 0.0}|Acc}
         end
      end
   end
in {PartitionFreqAcc Music P2T nil}
end