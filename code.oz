local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   % Put here the **absolute** path to the project files

   %TODO: MAKE SURE THIS IS COMMENTED WHEN SUBMITTING THE PROJECT
   % Uncomment one line or the other depending on who you are
   CWD = '/home/emile/OZ/LINFO1104-Maestroz-Group38/' % Emile's directory 
   %CWD = 'C:/Users/emile/OneDrive/2021-2022/Q2/Oz/LINFO1104-Maestroz-Group38/' % Emile's directory 
   %CWD = '/home/twelvedoctor/OZ/LINFO1104-Maestroz-Group38/' % Tania's directory
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.

   fun {NoteToExtended Note Duration}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:Duration instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of "silence" then silence(duration:Duration)
         [] [_] then note(name:Atom octave:4 sharp:false duration:Duration instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:Duration
                 instrument: none)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {DronePartition PartitionDrone Nbr}
      if(Nbr == 0) then
         nil
      else
         PartitionDrone.1| {DronePartition PartitionDrone Nbr-1}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   NoteList = notelist(0:shortnote(name:c sharp:false) 
                        1:shortnote(name:c sharp:true)
                        2:shortnote(name:d sharp:false) 
                        3:shortnote(name:d sharp:true) 
                        4:shortnote(name:e sharp:false) 
                        5:shortnote(name:f sharp:false) 
                        6:shortnote(name:f sharp:true) 
                        7:shortnote(name:g sharp:false) 
                        8:shortnote(name:g sharp:true) 
                        9:shortnote(name:a sharp:false) 
                        10:shortnote(name:a sharp:true) 
                        11:shortnote(name:b sharp:false))
  
   fun {TransposeNote ExtendedNote NumberTranspose}
      if(NumberTranspose >= 0) then
         if(ExtendedNote.sharp==false) then
            note(duration:ExtendedNote.duration instrument:ExtendedNote.instrument 
                  name:(NoteList.(({Abs NoteListNumber.(ExtendedNote.name) + NumberTranspose}) mod 12).name) 
                  octave:(ExtendedNote.octave + ({Abs (NoteListNumber.(ExtendedNote.name) + NumberTranspose)} div 12)) 
                  sharp:(NoteList.({Abs (NoteListNumber.(ExtendedNote.name) + NumberTranspose)} mod 12).sharp))
         else
            note(duration:ExtendedNote.duration instrument:ExtendedNote.instrument 
                  name:(NoteList.(({Abs (NoteListNumber.(ExtendedNote.name) + NumberTranspose + 1)}) mod 12).name) 
                  octave:(ExtendedNote.octave + (({Abs (NoteListNumber.(ExtendedNote.name) + NumberTranspose + 1)}) div 12)) 
                  sharp:(NoteList.(({Abs (NoteListNumber.(ExtendedNote.name) + NumberTranspose + 1)}) mod 12).sharp))
         end

      else
         if(ExtendedNote.sharp==false) then
            note(duration:ExtendedNote.duration 
                  instrument:ExtendedNote.instrument 
                  name:(NoteList.((NoteListNumber.(ExtendedNote.name) + {Abs (12 + NumberTranspose )}) mod 12).name) 
                  octave:(ExtendedNote.octave + {FloatToInt {Floor ({IntToFloat (NoteListNumber.(ExtendedNote.name) + NumberTranspose)} / 12.0)}}) 
                  sharp:(NoteList.((NoteListNumber.(ExtendedNote.name) + {Abs (12 + NumberTranspose )}) mod 12).sharp))
         else
            note(duration:ExtendedNote.duration instrument:ExtendedNote.instrument 
                  name:(NoteList.((NoteListNumber.(ExtendedNote.name) + 1 + {Abs (12 + NumberTranspose )}) mod 12).name) 
                  octave:(ExtendedNote.octave + {FloatToInt {Floor ({IntToFloat (NoteListNumber.(ExtendedNote.name) + 1 + NumberTranspose)} / 12.0)}}) 
                  sharp:(NoteList.((NoteListNumber.(ExtendedNote.name) + 1 + {Abs (12 + NumberTranspose )}) mod 12).sharp))
         end
      end
   end

   NoteListNumber = notelist(c:0
                             d:2
                             e:4
                             f:5
                             g:7
                             a:9
                             b:11)
                   
   fun {TransposePartition PartitionTranspose Semitones}
      if(PartitionTranspose == nil) then
         nil
      else
         case PartitionTranspose.1
         of nil then nil
         [] partition(X) then {TransposePartition {PartitionToTimedList X} Semitones}
         [] silence(duration:X) then silence(duration:X) | {TransposePartition PartitionTranspose.2 Semitones}
         [] note(duration:V instrument:W name:X octave:Y sharp:Z) then {TransposeNote note(duration:V instrument:W name:X octave:Y sharp:Z) Semitones} | {TransposePartition PartitionTranspose.2 Semitones}
         [] Name#Octave then {TransposeNote {NoteToExtended Name#Octave 1.0} Semitones} | {TransposePartition PartitionTranspose.2 Semitones}
         [] _|_ then {TransposePartition PartitionTranspose.1 Semitones} | {TransposePartition PartitionTranspose.2 Semitones}
         else
            {TransposeNote {NoteToExtended PartitionTranspose.1 1.0} Semitones} | {TransposePartition PartitionTranspose.2 Semitones}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   fun {ComputeDuration Partition Acc}
      if(Partition == nil) then
         Acc
      else
         case Partition.1
         of nil then Acc
         [] partition(X) then {ComputeDuration {PartitionToTimedList X} 0.0}
         [] silence(duration:X) then {ComputeDuration Partition.2 Acc+X}
         [] note(duration:V instrument:_ name:_ octave:_ sharp:_)  then {ComputeDuration Partition.2 (Acc+V)}
         [] _#_ then {ComputeDuration Partition.2 (Acc+1.0)}
         [] H|_ then 
            case H
            of nil then 
               {ComputeDuration Partition.2 Acc}
            else
               {ComputeDuration Partition.2 (Acc+{GetNoteLength Partition.1.1})}
            end
         else
            {ComputeDuration Partition.2 (Acc+1.0)}
         end
      end
   end


   fun {GetNoteLength Note}
      case Note
      of note(duration:V instrument:_ name:_ octave:_ sharp:_) then V
      else
         {NoteToExtended Note 1.0}.duration
      end
   end

   fun {DurationPartition Duration PartitionDuration}
      {StretchPartition PartitionDuration (Duration / {ComputeDuration PartitionDuration 0.0})}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      fun {StretchPartition PartitionStretch Factor}

         if(PartitionStretch == nil) then
            nil
         else
            case PartitionStretch.1
            of nil then nil
            [] partition(X) then {StretchPartition {PartitionToTimedList X} Factor}
            [] silence(duration:X) then silence(duration:X*Factor) | {StretchPartition PartitionStretch.2 Factor}
            [] note(duration:V instrument:W name:X octave:Y sharp:Z) then note(duration:V*Factor instrument:W name:X octave:Y sharp:Z) | {StretchPartition PartitionStretch.2 Factor}
            [] Name#Octave then {NoteToExtended Name#Octave Factor} | {StretchPartition PartitionStretch.2 Factor}
            [] _|_ then {StretchPartition PartitionStretch.1 Factor} | {StretchPartition PartitionStretch.2 Factor}
            else
               {NoteToExtended PartitionStretch.1 Factor} | {StretchPartition PartitionStretch.2 Factor}
            end
         end
      end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   fun {PartitionToTimedList Partition}
      if Partition == nil then 
         nil
      else
         case Partition.1
            of partition(X) then {PartitionToTimedList X}
            [] nil then {Append [nil] {PartitionToTimedList Partition.2}}
            [] stretch(1:X factor:Y) then  {Append {StretchPartition {PartitionToTimedList X} Y}  {PartitionToTimedList Partition.2}}
            [] drone(note:X amount:Y) then {Append {DronePartition {PartitionToTimedList [X]} Y} {PartitionToTimedList Partition.2}}
            [] transpose(1:X semitones:Y) then {Append {TransposePartition {PartitionToTimedList X} Y} {PartitionToTimedList Partition.2}}
            [] duration(1:X seconds:Y) then {Append {DurationPartition Y {PartitionToTimedList X}} {PartitionToTimedList Partition.2}}
            [] silence(duration:X) then silence(duration:X) | {PartitionToTimedList Partition.2}
            [] note(duration:V instrument:W name:X octave:Y sharp:Z) then note(duration:V instrument:W name:X octave:Y sharp:Z) | {PartitionToTimedList Partition.2}
            [] H|T then 
                case H
                of nil then [nil] | {PartitionToTimedList Partition.2}
                else
                    {PartitionToTimedList Partition.1} | {PartitionToTimedList Partition.2}
                end
            else  
               {NoteToExtended Partition.1 1.0} | {PartitionToTimedList Partition.2}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{MixAux P2T Music}
      if(Music==nil) then
         nil
      else
         case Music.1
         of nil then nil
         [] samples(X) then X | {Mix P2T Music.2}
         [] partition(X) then {PartitionFreq {P2T X} P2T} | {Mix P2T Music.2}
         [] wave(X) then {Project.readFile CWD#X} | {Mix P2T Music.2}
         [] merge(X) then {Merge {MergeAux X P2T}} | {Mix P2T Music.2}
         [] reverse(X) then {List.reverse {Mix P2T X}} | {Mix P2T Music.2}
         [] repeat(amount:X 1:Y) then {Repeat X {Mix P2T Y}} | {Mix P2T Music.2}
         [] loop(seconds:X 1:Y) then {Loop X {Mix P2T Y} {IntToFloat {List.length {Mix P2T Y}}}/44100.0} | {Mix P2T Music.2}
         [] clip(low:X high:Y 1:Z) then {Clip X Y {Mix P2T Z}} | {Mix P2T Music.2}
         [] echo(delay:X decay:Y 1:Z) then {Echo Y {PartitionFreq {P2T [partition([silence(duration:X)])]} P2T} {Mix P2T Z}} | {Mix P2T Music.2}
         [] cut(start:X finish:Y 1:Z) then {Cut X Y {Mix P2T Z}} | {Mix P2T Music.2}
         [] fade(start:X out:Y Z) then {Fade X Y {Mix P2T Z}} | {Mix P2T Music.2}
         else
            nil
         end
      end
   end

   fun{Mix P2T Music}
      {Flatten {MixAux P2T Music}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Frequency Hauteur}
      {Pow 2.0 ({IntToFloat Hauteur}/12.0)} * 440.0
   end

   fun{GetNoteHeight ExtendedNote} %TODO: CHECK IF THERE NEEDS TO BE A SPECIAL PROCESSING FOR CHORDS, NO MENTION OF IT IN THE SPECIFIATIONS
      if(ExtendedNote.sharp == false) then
         (NoteListNumber.(ExtendedNote.name) - NoteListNumber.a) + (12*ExtendedNote.octave - 48) 
      else
         ((NoteListNumber.(ExtendedNote.name) + 1) - NoteListNumber.a) + (12*ExtendedNote.octave - 48) 
      end
   end

   fun {PartitionFreq Music P2T}
      if(Music == nil) then
         nil
      else
         case Music.1
         of nil then {PartitionFreq Music.2 P2T}
         [] silence(duration:_) then {Append {SampleFrequency 0.0 Music.1.duration*44100.0 0.0} {PartitionFreq Music.2 P2T}}
         [] _|_ then {Append {Merge {PartitionFreqChord Music.1 1.0/{IntToFloat {List.length Music.1}} P2T}} {PartitionFreq Music.2 P2T}}
         else
            {Append {SampleFrequency {Frequency {GetNoteHeight Music.1}} Music.1.duration*44100.0 0.0} {PartitionFreq Music.2 P2T}}
         end
      end
   end

   fun {RemoveNil Lst}
      nil
   end

   fun{PartitionFreqChord Chord Intensity P2T}
      if(Chord == nil) then
         nil
      else
         case Chord.1
         of nil then nil
         else Intensity#{PartitionFreq {P2T [Chord.1]} P2T} | {PartitionFreqChord Chord.2 Intensity P2T}
         end
      end
   end

   fun {SampleFrequency Frequency NumberOfSamples Pos}
      if(Pos >= NumberOfSamples) then
         nil
      else
          0.5*{Sin (2.0*3.141592658979323846*Frequency*Pos)/44100.0} | {SampleFrequency Frequency NumberOfSamples Pos+1.0}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {MergeAux Musics P2T}
      case Musics
      of nil then nil
      [] H|T then
         {Mix P2T H.2} | {MergeAux T P2T}
      end
   end

   fun {Merge Musics}
      fun {MergeAcc Musics Acc}
         case Musics of nil then Acc
         [] H|T then {MergeAcc T {SumTwoLists {Multiply H} Acc}}
         end
      end
      in {MergeAcc Musics nil} 
   end

   fun {TakeMusic Music}
      case Music
      of _#L 
         then L
      else
         nil
      end
   end

   fun {Multiply Music}
      fun {MultiplyAcc Music Intensity Acc}
         case Music
         of nil then {List.reverse Acc}
         [] H|T then
            {MultiplyAcc T Intensity H*Intensity|Acc}
         end
      end
      in
         case Music
         of nil then nil
         [] X#L then
            {MultiplyAcc L X nil}
         else
            {MultiplyAcc Music 1.0 nil}
         end
   end

   
   fun {SumTwoLists L1 L2}
      fun {SumTwoListsAcc L1 L2 Acc}
         case L1 # L2
            of nil # nil then {List.reverse Acc}
            [] (H1|T1) # nil then 
               {SumTwoListsAcc T1 nil H1|Acc}
            [] nil # (H2|T2) then
               {SumTwoListsAcc nil T2 H2|Acc}
            [] (H1|T1) # (H2|T2) then 
               {SumTwoListsAcc T1 T2 H1+H2|Acc}
         end
      end
   in
      {SumTwoListsAcc L1 L2 nil}
   end

   fun {Repeat Amount Music}
      if(Amount == 0) then
         nil
      else
         Music | {Repeat Amount-1 Music}
      end
   end
   
   
   fun {Loop Duration Music MusicLength}
         {Append {Repeat {FloatToInt {Floor Duration/MusicLength}} Music} {List.take Music ({FloatToInt Duration - MusicLength*{Floor Duration/MusicLength}})*44100}}
   end

   fun {Clip Low High Music}
      fun {ClipAcc Low High Music Acc}
         case Music
         of nil then 
            {List.reverse Acc}
         [] H|T then
            if H < Low then
               {ClipAcc Low High T Low|Acc}
            elseif H > High then
               {ClipAcc Low High T High|Acc}
            else
               {ClipAcc Low High T H|Acc}
            end
         end
      end
      in {ClipAcc Low High Music nil}
   end

   fun {Echo Decay Mixer Music}
      {Merge [Decay#{Append Mixer Music} 1.0#Music]}
   end

   fun {Fade Start Out Music}
      {Append {FadeIn 1.0/(Start*44100.0) 0.0 {List.take Music {List.length Music}-({FloatToInt Out}*44100)}} 
               {FadeOut 1.0/(Out*44100.0) 1.0 {List.drop Music {List.length Music}-({FloatToInt (Out)}*44100)-1}}}
   end

   fun {FadeIn Increment CurrentIncrement Music}
      if(CurrentIncrement>=1.0) then
         Music
      else if(Music == nil) then
         nil
      else
         Music.1*CurrentIncrement | {FadeIn Increment CurrentIncrement+Increment Music.2} end
      end
   end

   fun{FadeOut Increment CurrentIncrement Music}
      if(Music == nil) then
         nil
      else
         Music.1*CurrentIncrement | {FadeOut Increment CurrentIncrement-Increment Music.2}
      end
   end
   
   fun {Cut Start Finish Music}
      {AppendCut (Finish-Start)*44100.0 {List.drop Music {FloatToInt Start*44100.0} } Start==0.0}
   end

   fun {AppendCut NumberOfElems Music StartAtZero}
      if(NumberOfElems==0.0 andthen StartAtZero==false) then 
         nil
      else
         if(Music == nil) then 
            0.0 | {AppendCut NumberOfElems-1.0 nil false}
         else
            Music.1 | {AppendCut NumberOfElems-1.0 Music.2 false}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Music2 = {Project.load CWD#'creation.dj.oz'}
   Music3 = {Project.load CWD#'example.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   %{Property.put print print(width:1000)}
   %{Property.put print print(depth:1000)}
   Start = {Time}
   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   %{Browse Music}
   %{Browse {PartitionToTimedList Music}}
   %{Browse {PartitionToTimedList [partition([duration(seconds:2.0 1:[a0 a0 [nil]])])]}}
   %{Browse {Mix PartitionToTimedList [partition([duration(seconds:2.0 1:[a0 a0 [nil]])])]}}
   %{Browse {Project.run Mix PartitionToTimedList [partition([duration(seconds:2.0 1:[a4 a3 [nil]])])] 'outnil.wav'}}
   %{Browse {PartitionToTimedList [partition([duration(seconds:2.0 1:[[nil]])])]}}
   %{Browse {GetNoteHeight note(duration:1.0 instrument:none name:a octave:5 sharp:false)}}
   %{Browse {Mix PartitionToTimedList [loop(1:[partition([c d e f g])] seconds:15.0)]}}
   %{Browse {Merge [0.5#[0.9 0.4 ~1.2 8.5 5.2] 0.6#[0.9 0.4 ~1.2] 0.8#[0.9 0.4 ~1.2]]}}
   %{Browse {Multiply 0.5#[5.0 6.0 8.0]}}
   %{Browse {Repeat 5 [0.9 9.0 4.0]}}
   %{Browse {Frequency 0}}
   %{Browse {SumTwoLists [5.0 6.0 8.0 7.0] [0.9 0.4 ~1.2 8.5 5.2]}}
   %{Browse {Clip ~0.4 0.8 [0.87 ~0.7 ~0.3 0.5]}}
   %{Browse {Mix PartitionToTimedList [partition([silence(duration:2.0)])]}}
   %{Browse {MergeAux [0.3#[partition([c d e f g])] 0.5#[partition([e f e c d])]] PartitionToTimedList}}
   %{Browse {Mix PartitionToTimedList [merge([0.3#[partition([c d e f g])] 0.5#[partition([e f e c d])]])]}}
   %{Browse {Mix PartitionToTimedList [echo(1:[partition([c d e f g])] delay:1.0 decay:0.4)]}}
   %{Browse {Project.run Mix PartitionToTimedList [echo(1:[partition([c d e f g])] delay:0.5 decay:0.5)] 'outecho.wav'}}
   %{Browse {Project.run Mix PartitionToTimedList [reverse(1:[partition([c d e f g])])] 'outrev.wav'}}
   %{Browse {List.take 1|2|3|4|5|nil 6}}
   %{Browse {Project.run Mix PartitionToTimedList [repeat(1:[partition([c d])] amount:4)] 'outrep.wav'}}
   %{Browse {Project.run Mix PartitionToTimedList [clip(1:[partition([c2 c3 a4 a5])] high:0.9 low:~0.2)] 'outclip.wav'}}
   %{Browse {PartitionToTimedList [drone(amount:3 note:a#4)]}}
   %{Browse {Project.run Mix PartitionToTimedList [fade(1:[partition([a4 a4 a4 a4 a4 a4 [nil]])] start:3.0 out:2.0)] 'outfade.wav'}}
   %{Browse {Project.run Mix PartitionToTimedList [fade(1:[partition([a4 a4 a4 a4 a4 a4])] start:1.0 out:2.0)] 'outfade.wav'}}
   %{Browse {Mix PartitionToTimedList [wave('wave/animals/pig.wav')]}}
   %{Browse {Project.run Mix PartitionToTimedList [wave('wave/animals/cat.wav')] 'outduck.wav'}}
   %{Browse {Cut 1.0 3.0 {Mix PartitionToTimedList [partition([c d e f g])]}}}
   %{Browse {Project.run Mix PartitionToTimedList [cut(1:[partition([c d e f g])] start:1.0 finish:10.0)] 'outcut.wav'}}
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {PartitionToTimedList [partition([transpose(semitones:~2 [c#4 c c])])]}}
   %{Browse {PartitionToTimedList Music3}}
   %{Browse {Mix PartitionToTimedList Music}}
   %{Browse {PartitionFreqChord [c d e] 1.0/3.0 PartitionToTimedList}}
   %{Browse {Project.run Mix PartitionToTimedList [loop(1:[partition([c d e f g])] seconds:16.0)] 'outloop.wav'}}
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   %{Browse {PartitionToTimedList Music2}}
   %{Browse {Project.run Mix PartitionToTimedList Music3 'out3.wav'}}
   {Browse {Project.run Mix PartitionToTimedList Music2 'out2.wav'}}
   {Browse "OK"}
   %{Browse Music}
   %{Browse  {PartitionFreq {PartitionToTimedList Music}}}
   %{Browse {Mix PartitionToTimedList [partition([a b c#4])]}}
   %{Browse {Mix PartitionToTimedList [partition([[c d]])]}}
   %{Browse {Project.run Mix PartitionToTimedList [partition([a silence transpose(semitones:~2 [c#4 c c stretch(factor:2.0 [c d e]) silence]) stretch(factor:3.0 [silence c c c [c c#5 c]]) duration(seconds:6.0 [silence b c5 d8 [d#3 e f]]) drone(amount:4 note:g#5) drone(amount:3 note:silence)]) ] 'out.wav'}}
   %{Browse {List.length Music.1.1}}
   %{Browse {Project.run Mix PartitionToTimedList [partition([transpose(semitones:~2 [c#4 c c stretch(factor:2.0 [c d e]) silence])])] 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
