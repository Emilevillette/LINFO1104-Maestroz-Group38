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


   fun {StretchPartition PartitionStretch Factor List}
      if(PartitionStretch == nil) then
         List
      else
         case PartitionStretch.1
         of nil then nil
         [] partition(X) then List | {StretchPartition {PartitionToTimedList X} Factor List}
         [] note(duration:V instrument:W name:X octave:Y sharp:Z) then {StretchPartition PartitionStretch.2 Factor (List | note(duration:V*Factor instrument:W name:X octave:Y sharp:Z))}
         [] _|_ then {StretchPartition PartitionStretch.2 Factor (List | {StretchPartition PartitionStretch.1 Factor nil}.2)}
         else
             {StretchPartition PartitionStretch.2 Factor (List | {NoteToExtended PartitionStretch.1 Factor})}
         end
      end
   end

   fun {DronePartition PartitionDrone Nbr List}
      if(Nbr == 0) then
         List
      else
         {DronePartition PartitionDrone Nbr-1 (List | PartitionDrone)}
      end
   end

   fun {ComputeDuration Partition Acc}
      if(Partition == nil) then
         Acc
      else
         case Partition.1
         of nil then nil
         [] partition(X) then {ComputeDuration {PartitionToTimedList X} 0.0}
         [] note(duration:V instrument:_ name:_ octave:_ sharp:_)  then {ComputeDuration Partition.2 (Acc+V)}
         [] _|_ then {ComputeDuration Partition.2 (Acc+{ComputeDuration Partition.1 0.0})}
         else
            {ComputeDuration Partition.2 (Acc+1.0)}
         end
      end
   end

   fun {DurationPartition Duration PartitionDuration Factor}
      Factor = Duration/{ComputeDuration PartitionDuration 0}
      {StretchPartition PartitionDuration Factor nil}
   end

   fun {PartitionToTimedList Partition}
      if Partition == nil then 
         nil
      else
         case Partition.1
            of partition(X) then {PartitionToTimedList {Append [[c c c]] X}} %TODO: REMOVE THE APPEND
            [] stretch(1:X factor:Y) then  {StretchPartition X Y nil}.2 | {PartitionToTimedList Partition.2} 
            [] drone(note:X amount:Y) then {DronePartition X Y nil}.2 | {PartitionToTimedList Partition.2}
            [] transpose(X) then X | {PartitionToTimedList Partition.2}
            [] duration(1:X seconds:Y) then {DurationPartition X Y 0.0}.2
            [] note(duration:V instrument:W name:X octave:Y sharp:Z) then note(duration:V instrument:W name:X octave:Y sharp:Z) | {PartitionToTimedList Partition.2}
            [] _|_ then {PartitionToTimedList Partition.1} | {PartitionToTimedList Partition.2}
            else  {NoteToExtended Partition.1 1.0} | {PartitionToTimedList Partition.2}
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile CWD#'wave/animals/cow.wav'}
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
   {Browse Music}
   local NewMusic in
      NewMusic = {List.append [[c c c]] Music}
      % NEWMUSIC WITH CHORDS, MUSIC WITHOUT
      % {Browse NewMusic}
      {Browse {PartitionToTimedList Music}}
      {Browse {ComputeDuration Music 0.0}}
   end
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
