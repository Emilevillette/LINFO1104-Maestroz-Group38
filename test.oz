declare
fun {SumTwoLists L1 L2}
   if(L1 == nil andthen L2 == nil) then
      nil
   elseif(L2 == nil) then
      L1.1 | {SumTwoLists L1.2 nil}
   elseif(L1 == nil) then
      L2.1 | {SumTwoLists nil L2.2}
   else
      L1.1 + L2.2 | {SumTwoLists L1.2 L2.2} 
    end
end
{Browse {SumTwoLists [1.0 2.0 3.0 4.0] [4.2 15.2]}}