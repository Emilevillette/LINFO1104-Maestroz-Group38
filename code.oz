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
         of [_] then
            note(name:Atom octave:4 sharp:false duration:Duration instrument:none)
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
   fun {StretchPartition PartitionStretch Factor}
      %{Browse PartitionStretch}
      fun {StretchPartitionAcc PartitionStretch Factor Acc} 
         if(PartitionStretch == nil) then
            Acc
         else
            case PartitionStretch.1
            of nil then Acc
            else
               {StretchPartitionAcc PartitionStretch.2 Factor ({NoteToExtended PartitionStretch.1 Factor} | Acc)}
            end
         end
      end
   in
      
      {StretchPartitionAcc PartitionStretch Factor nil}
   end

   fun {PartitionToTimedList Partition}
      fun {PartitionToTimedListAcc Partition Acc}
         if Partition == nil then 
            Acc
         else
            case Partition.1
               of partition(X) then {PartitionToTimedListAcc X Acc}
               [] stretch(1:X factor:Y) then  {PartitionToTimedListAcc Partition.2 ({StretchPartition X Y} | Acc)} 
               [] drone(X) then {PartitionToTimedListAcc Partition.2 (X | Acc)}
               [] transpose(X) then {PartitionToTimedListAcc Partition.2 (X | Acc)}
               else  {PartitionToTimedListAcc Partition.2 ({NoteToExtended Partition.1 1.0} | Acc)}
            end
         end
      end
   in
      {Browse Partition}
      {PartitionToTimedListAcc Partition nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      fun {MixAcc P2T Music Acc}
         %truc du genre pour convertir en 44100 Hz 0.5*(Float, sin (3.141592658979323846*2.0*{IntToFloat I-1}*F))
      end
      {Project.readFile CWD#'wave/animals/cow.wav'}
   end


   fun {Reverse Music}
      fun {ReverseAcc Music Acc}
         case Music
            of nil then Acc|nil
            [] H|T then {ReverseAcc Music.2 Music.1|Acc}
         end
      end
   end

   fun {Repeat Amount Music}
      fun {RepeatAcc Amount Music Acc}
         if Amount == 0 
            then Acc|nil
         else
            {RepeatAcc Amount-1 Music Acc|Music}
         end
      end
   end

   fun {Loop Duration Music}
      fun {LoopAcc Duration Music Acc}
         if Duration == 0
            then Acc|nil
         else
            case Music
               of nil then {LoopAcc Duration-1 Music}
               [] H|T then {LoopAcc Duration-1 T Acc|H}
            end
         end   
      end
   end

   fun {Clip Low High Music}
      fun {ClipAcc Low High Music Acc}

      end
   end

   fun {Merge Music}
      fun {MergeAcc Music Acc}
         
      end
   end

   fun {Echo Delay Music}
      fun {EchoAcc Delay Music Acc}
         
      end
   end

   fun {Fade Start Out Music}
      fun {FadeAcc Start Out Music Acc} 
      end
   end

   fun {Cut Start Finish Music}
      fun {CutAcc Music Acc} 
      end
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   {Browse {PartitionToTimedList Music}}
   {Browse "I'm done"}
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
