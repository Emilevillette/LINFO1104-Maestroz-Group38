local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   % Put here the **absolute** path to the project files

   %TODO: MAKE SURE THIS IS COMMENTED WHEN SUBMITTING THE PROJECT
   % Uncomment one line or the other depending on who you are
   CWD = '/home/emile/OZ/LINFO1104-Maestroz-Group38/' % Emile's directory 
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
         of nil then nil
         [] partition(X) then {ComputeDuration {PartitionToTimedList X} 0.0}
         [] silence(duration:X) then {ComputeDuration Partition.2 Acc+X}
         [] note(duration:V instrument:_ name:_ octave:_ sharp:_)  then {ComputeDuration Partition.2 (Acc+V)}
         [] _#_ then {ComputeDuration Partition.2 (Acc+1.0)}
         [] _|_ then {ComputeDuration Partition.2 (Acc+{GetNoteLength Partition.1.1})}
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
            [] stretch(1:X factor:Y) then  {Append {StretchPartition {PartitionToTimedList X} Y}  {PartitionToTimedList Partition.2}}
            [] drone(1:X amount:Y) then {Append {DronePartition {PartitionToTimedList X} Y} {PartitionToTimedList Partition.2}}
            [] transpose(1:X semitones:Y) then {Append {TransposePartition {PartitionToTimedList X} Y} {PartitionToTimedList Partition.2}}
            [] duration(1:X seconds:Y) then {Append {DurationPartition {IntToFloat Y} {PartitionToTimedList X}} {PartitionToTimedList Partition.2}}
            [] silence(duration:X) then silence(duration:X) | {PartitionToTimedList Partition.2}
            [] note(duration:V instrument:W name:X octave:Y sharp:Z) then note(duration:V instrument:W name:X octave:Y sharp:Z) | {PartitionToTimedList Partition.2}
            [] _|_ then {PartitionToTimedList Partition.1} | {PartitionToTimedList Partition.2}
            else  
               {NoteToExtended Partition.1 1.0} | {PartitionToTimedList Partition.2}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      fun {MixAcc P2T Music Acc}
        %{Project.readFile CWD#'wave/animals/cow.wav'}
         %truc du genre pour convertir en 44100 Hz 0.5*(Float, sin (3.141592658979323846*2.0*{IntToFloat I-1}*F))
         case Music
         of H|T then
            case H
            of samples(X) then
               {MixAcc P2T T X|Acc}
            [] partition(X) then 
               {MixAcc P2T T {PartitionFreq {P2T X}}|Acc}
            [] wave(X) then 
               {MixAcc P2T T {Project.load (CWD#X)}|Acc}
            [] merge(X) then 
               {MixAcc P2T T {Merge X}|Acc}
            %filtres
            end
         else
            Acc
         end
      end
      in {MixAcc P2T Music nil}
   end

   fun {Frequency Hauteur}
      {Pow 2.0 ({IntToFloat Hauteur}/12.0)} * 440.0
   end

   fun{GetNoteHeight ExtendedNote}
      if(ExtendedNote.sharp == false) then
         (NoteListNumber.(ExtendedNote.name) - NoteListNumber.a) + (12*ExtendedNote.octave - 48) 
      else
         ((NoteListNumber.(ExtendedNote.name) + 1) - NoteListNumber.a) + (12*ExtendedNote.octave - 48) 
      end
   end

   fun {PartitionFreq Music}
      if(Music == nil) then
         nil
      else
         case Music.1
         of nil then nil
         [] silence(duration:_) then 0 | {PartitionFreq Music.2}
         [] _|_ then {PartitionFreq Music.1} | {PartitionFreq Music.2}
         else
            {Frequency {GetNoteHeight Music.1}} | {PartitionFreq Music.2}
         end
      end
   end


   fun {Merge Musics}
      fun {MergeAcc Musics Acc}
         Acc
         %case Musics
         %of H|T then
          %  case H
      end
      in {MergeAcc Musics nil} 
   end


   fun {Intensity Music}
      case Music
      of X#L 
         then X
      else 
         nil
      end
   end

   fun {Multiply Music}
      fun {MultiplyAcc Music X Acc}
         if Music == nil then
            nil
         else
            case Music.1
            of nil then
               Acc
            [] H then
               {Append Acc H*X} | {MultiplyAcc Music.2 X Acc}
            end
         end
      end
      in 
         {MultiplyAcc Music.2 {Intensity Music} nil}
   end

   fun {AddElementLists L}
      L
   end

   {Browse {Multiply 0.5#[5.0 6.0 5.0]}}


   fun {Reverse Music}
      fun {ReverseAcc Music Acc}
         case Music
         of H|T then
            {ReverseAcc T {Append H|nil Acc}}
         else
            Acc
         end
      end
      in 
         {ReverseAcc Music nil}
   end


   fun {Repeat Amount Music}
      fun {RepeatAcc Amount Music Music1 Acc}
         if Music == nil then
            {RepeatAcc Amount-1 Music1 Music1 Acc}
         else
            if Amount == 0 then
               Acc
            else
               case Music.1
               of H then
                  {Append Acc H} | {RepeatAcc Amount Music.2 Music1 Acc}
               else
                  nil
               end
            end
         end
      end
      in {RepeatAcc Amount Music Music nil}
   end

   {Browse {Repeat 5 [0.9 9.0 4.0]}}

   fun {Loop Duration Music}
      'bruhhhhh'
   end

   fun {Clip Low High Music}
      fun {ClipAcc Low High Music Acc}
         Acc
      end
      in {ClipAcc Low High Music nil}
   end

   fun {Echo Delay Music}
      fun {EchoAcc Delay Music Acc}
         Acc
      end
      in {EchoAcc Delay Music nil}  
   end

   fun {Fade Start Out Music}
      fun {FadeAcc Start Out Music Acc}
         Acc
      end
      in {FadeAcc Start Out Music nil}
   end

   fun {Cut Start Finish Music}
      fun {CutAcc Start Finish Music Acc}
         Acc
      end
      in {CutAcc Start Finish Music nil} 
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   {Property.put print print(width:1000)}
   {Property.put print print(depth:1000)}
   Start = {Time}
   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   %{Browse Music}
   %{Browse {PartitionToTimedList Music}}
   {Browse {GetNoteHeight note(duration:1.0 instrument:none name:a octave:5 sharp:false)}}
   {Browse {Mix PartitionToTimedList Music}}
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
