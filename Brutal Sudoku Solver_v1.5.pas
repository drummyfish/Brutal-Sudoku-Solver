program BrutalSudokuSolver;

{                O==============================O
                 |                              |
                 | This program should be able  |
                 | to solve a sudoku riddle.    |
                 |                              |
                 |                              |
                 | by: Miloslav "TastyFish" Èíž |
                 | year: 2008                   |
                 |                              |
                 O==============================O                                   }

uses  crt;

const VERSION = '1.5';                            { current program version         }
      POS_X = 2;                                  { position of the upper left      }
      POS_Y = 3;                                  {   corner at the screen          }

type  TNumber = 0..9;                             { only numbers 1..9 are allowed   } 
                                                  { 0 = unknown number              }
      TSet    = set of TNumber;

      TSquare = record
                 Solution : TNumber;              { solution of a single square     }
                 PossibleNumbers : TSet;          { set of possible solutions       }
               end;

      TSudoku = array [1..9, 1..9] of TSquare;    { a sudoku sheet                  }

var   Sudoku  : TSudoku;                          { our sudoku sheet variable       }
      OK      : Boolean;                          { (un)succes of solving           }
      Choice  : Char;                             { to capture user's choice (y/n)  }
      A, B    : Byte;                             { used for reseting the sudoku    }

{-----------------------------------------------------------------------------------}
function GetSetSize (S: TSet): Byte;              { returns a size of a set (= how  }
                                                  {   many TNumbers it contains)    }
var Size, N: Byte;

begin
  Size := 0;
  for N:=1 to 9 do
    if N in S then
      Size := Size + 1;
  GetSetSize := Size;
end; {GetSetSize}

{-----------------------------------------------------------------------------------}
procedure DrawSudoku (What: TSudoku; WhereX, WhereY: byte);             
                                                  { draws the "What" sudoku at the  }                 
var Xx, Yy: Byte;                                 {   screen                        }

begin
  GoToXY (WhereX,WhereY);
  TextColor (LightRed);
  WriteLn ('ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿');

  for Yy := 1 to 9 do begin

    for Xx:=2 to WhereX do
      Write (' ');

    for Xx := 1 to 9 do begin

      if (Xx-1) mod 3 = 0 then
        TextColor (LightRed)
        else
          TextColor (White); 
      Write ('³');
      TextColor (LightGreen);
      if What[Xx,Yy].Solution <> 0 then
        Write (What[Xx,Yy].Solution,' ')
        else
          Write ('  ');
      if Xx=9 then begin
        TextColor (LightRed);
        Writeln ('³');
      end;        
    end;

    for Xx:=2 to WhereX do
      Write (' ');

    TextColor (LightRed);

    case Yy of
      3,6: WriteLn ('ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´');
        9: WriteLn ('ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ')
      else begin
             Write ('Ã');
             TextColor (White);
             Write ('ÄÄÅÄÄÅÄÄ'); 
             TextColor (LightRed);
             Write ('Å');
             TextColor (White);
             Write ('ÄÄÅÄÄÅÄÄ'); 
             TextColor (LightRed);
             Write ('Å'); 
             TextColor (White);
             Write ('ÄÄÅÄÄÅÄÄ'); 
             TextColor (LightRed);
             Writeln ('´'); 
           end;
    end; { case }
  end;

  TextColor (White);
end; { DrawSudoku }

{-----------------------------------------------------------------------------------}
procedure GetNumbers (var ToWhat: TSudoku; XWhere, YWhere: Byte);                     
                                                  { allows the user to set the      }
var Xxx, Yyy: byte;                               {   numbers at the beggining      }
    Key     : char;                               { key being pressed               }
                               
begin
  Xxx := 1;                                       { set cursor to 1;1               }
  Yyy := 1;
  repeat
    DrawSudoku(ToWhat,POS_X,POS_Y);               { redraw the sheet                }
    GoToXY (1+3*(Xxx-1)+XWhere,1+2*(Yyy-1)+YWhere);
    key := ReadKey;
    case key of
      #72: if Yyy>1 then                          { up                              }
             Yyy := Yyy-1;
      #77: if Xxx<9 then                          { right                           }
             Xxx := Xxx+1;
      #80: if Yyy<9 then                          { down                            }
             Yyy := Yyy+1;
      #75: if Xxx>1 then                          { left                            }
             Xxx := Xxx-1;
      #8 : ToWhat[Xxx,Yyy].Solution := 0;         { backspace = delete number       }
      '1': ToWhat[Xxx,Yyy].Solution := 1;         { and 1..9 values:                }
      '2': ToWhat[Xxx,Yyy].Solution := 2;
      '3': ToWhat[Xxx,Yyy].Solution := 3;
      '4': ToWhat[Xxx,Yyy].Solution := 4;
      '5': ToWhat[Xxx,Yyy].Solution := 5;
      '6': ToWhat[Xxx,Yyy].Solution := 6;
      '7': ToWhat[Xxx,Yyy].Solution := 7;
      '8': ToWhat[Xxx,Yyy].Solution := 8;
      '9': ToWhat[Xxx,Yyy].Solution := 9;
    end;
  until key = #13;                                { until enter pressed             }
end; { GetNumbers }

{-----------------------------------------------------------------------------------}
function Check (No, PX, PY: TNumber; Whr: Tsudoku): Boolean;
                                                  { returns true if the "No" number }
var O, P: TNumber;                                {   does not violate the rules    }
    CheckOK: Boolean;                             {   when at PX;PY position in the }
                                                  {   "Whr" sudoku                  }
begin
  CheckOK := true;
  
  for O := 1 to 9 do                              { check column and line           }
    if ( (No = Whr[PX,O].Solution) and (O<>PY) ) or ( (No=Whr[O,PY].Solution) and (O<>PX) ) then begin
      CheckOK := false;
      Break;
    end;

  for O := 1 to 3 do                              { check a 3x3 square              }
    for P := 1 to 3 do
      if (No = Whr[P+((PX-1) div 3)*3, O+((PY-1) div 3)*3].Solution) and
         ( ( P+((PX-1) div 3)*3 <> PX ) or ( O+((PY-1) div 3)*3 <> PY) ) then begin
        CheckOK := false;
        Break;
      end;

  Check := CheckOK;
end; { Check }

{-----------------------------------------------------------------------------------}
procedure FindPossibleNumbers (var Where: TSudoku; var Done: Boolean);
                                                  { makes a set of possible solluti-}
var X, Y, I: Byte;                                {   ons for each square in "Where"}
                                                  {   , returns false if any square }
begin                                             {   remains unfilled              }
  for Y := 1 to 9 do
    for X := 1 to 9 do
      if Where[X,Y].Solution = 0 then begin       { if unsolved yet                 }
      Where[X,Y].Possiblenumbers := Where[X,Y].Possiblenumbers - [0];
      Done := false;
      for I := 1 to 9 do
        if Check (I,X,Y,Where) then
          Where[X,Y].Possiblenumbers := Where[X,Y].Possiblenumbers + [I]
          else
            Where[X,Y].Possiblenumbers := Where[X,Y].Possiblenumbers - [I];
      end
      else
        Where[X,Y].Possiblenumbers := [];         { empty set for solved squares    } 
end; { FindPossibleNumbers }

{-----------------------------------------------------------------------------------}
procedure FindFinalNumbers1 (var Where: TSudoku; var Change: Boolean);
                                                  { makes final solution of squares }
var X, Y, I: Byte;                                {   from sets of their possible   }
                                                  {   numbers (method 1), returns,  }
begin                                             {   false if no change happened   }
  for Y := 1 to 9 do
    for X := 1 to 9 do
      if Where[X,Y].Solution = 0 then
        if GetSetSize (Where[X,Y].PossibleNumbers) = 1 then
          for I := 1 to 9 do
            if I in Where[X,Y].PossibleNumbers then begin
              Where[X,Y].Solution := I;
              Change := true;
            end;
end; { FindFinalNumbers1 }

{-----------------------------------------------------------------------------------}
procedure FindFinalNumbers2 (var Where: TSudoku; var Change: Boolean);
                                                  { makes final solution of squares }
var X, Y, I, J, K, L: Byte;                       {   from sets of their possible   }
                                                  {   numbers (method 2), returns,  }
begin                                             {   false if no change happened   }
  for Y := 1 to 9 do                              { for each line do:               }
    for I := 1 to 9 do begin                      { -  check whether there is a     }
      J := 0;                                     {    line-unique number ( J =     }
      for X := 1 to 9 do                          {    number count, I = current    }
        if I in Where[X,Y].PossibleNumbers then   {    number being checked )       }
          J := J + 1;
      if J = 1 then                               { -  if so then find it again     }
        for X := 1 to 9 do
          if I in Where[X,Y].PossibleNumbers then begin
            Where[X,Y].Solution := I;             { -  and make it the solution     }
            Change := true;
            Break;
          end;            
    end;

  for X := 1 to 9 do                              { do the same for each column:    }
    for I := 1 to 9 do begin                      { -  check whether there is a     }
      J := 0;                                     {    column-unique number ( J =   }
      for Y := 1 to 9 do                          {    number count, I = current    }
        if I in Where[X,Y].PossibleNumbers then   {    number being checked )       }
          J := J + 1;
      if J = 1 then                               { -  if so then find it again     }
        for Y := 1 to 9 do
          if I in Where[X,Y].PossibleNumbers then begin
            Where[X,Y].Solution := I;             { -  and make it the solution     }
            Change := true;
            Break;
          end;            
    end;

  for K := 0 to 2 do                              { and do the sam for each 3x3 sqr:}
    for L := 0 to 2 do                            { K and L define the "3x3 square" }
      for I := 1 to 9 do begin                    {   currently being checked       }
       J := 0;
       for Y := 1 to 3 do
          for X := 1 to 3 do
            if I in Where[X+L*3,Y+K*3].PossibleNumbers then
              J := J + 1;
        if J = 1 then
          for Y := 1 to 3 do
            for X := 1 to 3 do
              if I in Where[X+L*3,Y+K*3].PossibleNumbers then begin
                Where[X+L*3,Y+K*3].Solution := I;
                Change := true;
              end;
      end;  
end; { FindFinalNumbers2 }

{-----------------------------------------------------------------------------------}
procedure SolveSudoku (var Wht: TSudoku; var GotSolution: Boolean);
                                                  { attempts to solve a sudoku,     }
var Solved, Changed: Boolean;                     {   returns true if solved        }                 

begin

  repeat
    Changed := false;                             { to detect if any change happened}
    Solved := true;                               { let's suppose the solution has  }
                                                  {   been found                    }    
    FindPossibleNumbers (Wht, Solved);
    FindFinalNumbers1 (Wht, Changed);
    FindFinalNumbers2 (Wht, Changed);                                                
  until Solved or not(Changed);                   { repeat until solved or not      }
                                                  {   changed (= no solution)       } 
  if Solved then
    GotSolution :=true
    else
      GotSolution :=false;
 
end; { SolveSudoku }


{-----------------------------------------------------------------------------------}
procedure BruteForce (var Sud: TSudoku; var Okay: Boolean);
                                                  { attempts to solve a sudoku      }
var XPos, YPos: Byte;                             {   using a brute force method    }
    Nr: TNumber;
    SquareCoordsList: array[1..81,'X'..'Y'] of TNumber;
    ListLength: Byte;
    NumberAdded: Boolean;

begin
  ListLength := 0;                                { make a list of empty squares'   }
  for YPos := 1 to 9 do                           {   coordination and remember its }
    for XPos := 1 to 9 do                         {   length                        }
      if Sud[XPos,YPos].Solution = 0 then begin
        ListLength := ListLength + 1;
        SquareCoordsList[ListLength,'X'] := XPos;
        SquareCoordsList[ListLength,'Y'] := YPos;
      end;

  XPos := 1;                                      { from now XPos = position in the }
  Okay := true;                                   {   list of empty squares         }
  repeat
    NumberAdded := false;

    for Nr := 1 to 9 do
      if( Sud[SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y']].Solution + Nr <= 9 )
        and 
        ( Check (Sud[SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y']].Solution + Nr,
                SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y'],Sud) )
        then begin
          NumberAdded := true;
          Sud[SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y']].Solution :=
          Sud[SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y']].Solution + Nr;
          Break;
        end;

   if NumberAdded then
      XPos := XPos + 1
      else begin
        Sud[SquareCoordsList[XPos,'X'],SquareCoordsList[XPos,'Y']].Solution := 0;
        if XPos > 1 then
          XPos := XPos - 1
          else begin
            Okay := false;
            Break;
          end;
      end;    
    DrawSudoku(Sud,POS_X,POS_Y);    
  until XPos > ListLength;                        { till we reach the end           }
end; { BruteForce }

{===================================================================================}
{                                     Program                                       }
{===================================================================================}

begin { program }

  ClrScr;
  WriteLn ('  Vita vas program BrutalSudokuSolver (v',VERSION,', autor: Miloslav "TastyFish" Ciz)    ');
  WriteLn ('-------------------------------------------------------------------------------');
  WriteLn;
  WriteLn ('  Tento program se snazi hledat reseni hadanky sudoku podle zadani, ktere  '); 
  WriteLn ('  dostane. Nejdriv se pokusi aplikovat logicke metody reseni, ktere vsak   ');
  WriteLn ('  nejsou 100% uspesne, proto od verze 1.5 nabizi take moznost metody Brute ');
  WriteLn ('  Force (casove narocnejsi, avsak s jistotou uspechu). Chtel bych Vas take ');
  WriteLn ('  upozornit na chybu, ktera obcas nastane pri zadavani cisel a zpusobi, ze ');
  WriteLn ('  se cislo nezobrazi hned, ale az po zadani nekolika dalsich cisel. Tato   ');
  WriteLn ('  drobnost nijak neovlivni beh programu a presto, ze se nejedna o chybu mou');
  WriteLn ('  ale prekladace, se za ni omlouvam. Doufam, ze Vam bude program jakkoli   ');
  WriteLn ('  uzitecnym :)                                                             ');

  Write ('- Pokracujte stiskem klavesy ');
  TextColor (LightRed);
  Write ('[ENTER]');
  TextColor (White);
  Write (': ');
  ReadLn;

  repeat
    for A := 1 to 9 do                            { reset: set all squares to empty}
      for B := 1 to 9 do
        Sudoku[B,A].Solution := 0;

    ClrScr;
    Write ('    BrutalSudokuSolver ',VERSION);
    GetNumbers (Sudoku,POS_X,POS_Y);
    SolveSudoku (Sudoku,OK);
    DrawSudoku (Sudoku,POS_X,POS_Y);
    GoToXY(1,22);

    if not(OK) then begin
      WriteLn('Program zatim nedokazal nalezt reseni. Ma pouzit metodu Brute Foce? (a/n)');
      repeat
        Choice := ReadKey;                        { get an answer                  }
      until choice in ['a','n'];
      if choice = 'a' then
        BruteForce (Sudoku,OK);
    end;
    
    Writeln;
    if not(OK) then
      Write('Sudoku nema reseni. ');
    
    Write('Prejete si pokracovat? (a/n)');        { continue?                      } 
 
    repeat
      Choice := ReadKey;                          { get an answer                  }
    until choice in ['a','n'];                    {   which can only be 'a' or 'n' }
  until choice='n';
  
  ClrScr;
  Write('Nashledanou :p');                        { say "goodbye"                  }
  ReadLn;                                         { and wait for enter             }

end. { program }