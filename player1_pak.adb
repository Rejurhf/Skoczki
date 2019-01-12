-- Rejurhf
-- 4.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io, GNAT.OS_Lib;
use Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io, GNAT.OS_Lib;

package body Player1_Pak is
  -- Type for board
  type Array2DType is array (0..7, 0..7) of Integer;
  -- Type with words style
  type Atrybuty is (Czysty, Jasny, Podkreslony, Negatyw, Migajacy, Szary);

  protected Ekran  is
    -- Printing in console
    procedure Pisz_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty);
    procedure Pisz_Float_XY(X, Y: Positive;
                            Num: Float;
                            Pre: Natural := 3;
                            Aft: Natural := 2;
                            Exp: Natural := 0;
                            Atryb : Atrybuty := Czysty);
    procedure Czysc;
    procedure Tlo;
  end Ekran;

  protected body Ekran is
    function Atryb_Fun(Atryb : Atrybuty) return String is
      (case Atryb is
        when Jasny => "1m", when Podkreslony => "4m", when Negatyw => "7m",
        when Migajacy => "5m", when Szary => "2m", when Czysty => "0m");

    function Esc_XY(X,Y : Positive) return String is
      ( (ASCII.ESC & "[" & Trim(Y'Img,Both) & ";" & Trim(X'Img,Both) & "H") );

    procedure Pisz_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty) is
      Przed : String := ASCII.ESC & "[" & Atryb_Fun(Atryb);
    begin
      Put( Przed);
      Put( Esc_XY(X,Y) & S);
      Put( ASCII.ESC & "[0m");
    end Pisz_XY;

    procedure Pisz_Float_XY(X, Y: Positive;
                            Num: Float;
                            Pre: Natural := 3;
                            Aft: Natural := 2;
                            Exp: Natural := 0;
                            Atryb : Atrybuty := Czysty) is

      Przed_Str : String := ASCII.ESC & "[" & Atryb_Fun(Atryb);
    begin
      Put( Przed_Str);
      Put( Esc_XY(X, Y) );
      Put( Num, Pre, Aft, Exp);
      Put( ASCII.ESC & "[0m");
    end Pisz_Float_XY;

    procedure Czysc is
    begin
      Put(ASCII.ESC & "[2J");
    end Czysc;

    procedure Tlo is
    begin
      Ekran.Czysc;
      Ekran.Pisz_XY(1,1,"===== Skoczki =====", Atryb=>Migajacy);
      Ekran.Pisz_XY(2,3,"1 ");
      Ekran.Pisz_XY(2,4,"2 ");
      Ekran.Pisz_XY(2,5,"3 ");
      Ekran.Pisz_XY(2,6,"4 ");
      Ekran.Pisz_XY(2,7,"5 ");
      Ekran.Pisz_XY(2,8,"6 ");
      Ekran.Pisz_XY(2,9,"7 ");
      Ekran.Pisz_XY(2,10,"8 ");
      Ekran.Pisz_XY(4,11,"H G F E D C B A");
    end Tlo;
  end Ekran;

  procedure ArrayToStrPrint(X,Y: Positive; Board: Array2DType) is
    -- Print board in console, X,Y are starting points
    Pos: Integer;
  begin
    for i in Integer range 0..7 loop
      Pos := Y;
      for j in Integer range 0..7 loop
        -- to invert array it is 7-i insted of i
        case Board(7-i,7-j) is
          when 1 =>
            Ekran.Pisz_XY(Pos,X+i, "B");
            Pos := Pos + 1;
          when 2 =>
            Ekran.Pisz_XY(Pos,X+i, "C");
            Pos := Pos + 1;
          when others =>
            Ekran.Pisz_XY(Pos,X+i, ".");
            Pos := Pos + 1;
        end case;
        if j<7 then
          Ekran.Pisz_XY(Pos,X+i, " ");
          Pos := Pos + 1;
        end if;
      end loop;
    end loop;
    Ekran.Pisz_XY(1,15, "");
  end ArrayToStrPrint;

  function GetInput(StartingPoint : Natural) return String is
    -- get input (fe. a8), StartingPoint is position where input will be shown
    -- number of line
    Input  : String (1..10);
    Output : String (1..10);
    len    : Natural := 0;
    Flag   : Boolean := False;
  begin
    while (Flag = False) loop
      -- clean line before next input
      Ekran.Pisz_XY(1,StartingPoint, 20*' ', Atryb=>Czysty);
      Ekran.Pisz_XY(1,StartingPoint, ">: " );
      Get_Line(Input, len);
      Output := Input;
      if len >= 2 and ((Input(1) >= 'a' and Input(1) <= 'h') or
                       (Input(1) >= 'A' and Input(1) <= 'H')) then
        if (Input(2) >= '1' and Input(2) <= '8') then
          Flag := True;
        end if;
      elsif len >= 2 and (Input(1) >= '1' and Input(1) <= '8') then
        if ((Input(2) >= 'a' and Input(2) <= 'h') or
            (Input(2) >= 'A' and Input(2) <= 'H')) then
          -- invert position of input (8a -> a8)
          Output(1) := Input(2);
          Output(2) := Input(1);
          Flag := True;
        end if;
      elsif len = 1 and (Input(1) = 'q' or Input(1) = 'Q') then
          GNAT.OS_Lib.OS_Exit (0);
      end if;
    end loop;
    return Output;
  end GetInput;

  function ConvertToPos(C : Character) return Integer is
    -- convert character to integer (a->0, 8->0, h->7, 1->7)
  begin
    case C is
      when '8' => return 0;
      when 'A' => return 0;
      when 'a' => return 0;
      when '7' => return 1;
      when 'B' => return 1;
      when 'b' => return 1;
      when '6' => return 2;
      when 'C' => return 2;
      when 'c' => return 2;
      when '5' => return 3;
      when 'D' => return 3;
      when 'd' => return 3;
      when '4' => return 4;
      when 'E' => return 4;
      when 'e' => return 4;
      when '3' => return 5;
      when 'F' => return 5;
      when 'f' => return 5;
      when '2' => return 6;
      when 'G' => return 6;
      when 'g' => return 6;
      when '1' => return 7;
      when 'H' => return 7;
      when 'h' => return 7;
      when others => return 7;
    end case;
  end ConvertToPos;

  procedure MovePawn(Board : in out Array2DType) is
    -- checking if move is correct within rules
    -- Input of Pawn and Goal in string
    Pawn,Goal : String (1..10);
    -- Positions from where and where to move Pawn
    X1,X2,Y1,Y2 : Integer;
    -- values of positions
    PawnVal, GoalVal : Integer;
    -- direction of move
    Left, Right : Boolean;
    -- is move allowed
    Move : Boolean;
    -- boolean to exit for loop
    ExitLoop : Boolean;
  begin
    -- clean before input
    Ekran.Pisz_XY(1,13, 20*' ', Atryb=>Czysty);
    Ekran.Pisz_XY(1,14, 20*' ', Atryb=>Czysty);
    Left := False;
    Right := False;
    Move := False;
    ExitLoop := False;
      
    Pawn := GetInput(13);
      
    -- convert input to integers
    X1 := ConvertToPos(Pawn(2));
    Y1 := ConvertToPos(Pawn(1));
      
    if Board(X1, Y1) = 1 then
        Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
        Ekran.Pisz_XY(1,16, "To nie twoj pionek");
        MovePawn(Board);
    elsif Board(X1, Y1) = 0 then
        Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
        Ekran.Pisz_XY(1,16, "Nie ma tam zadnego pionka");
        MovePawn(Board);
    else
	Goal := GetInput(14);
      
        -- convert input to integers  
        X2 := ConvertToPos(Goal(2));
        Y2 := ConvertToPos(Goal(1));
        
        if Y2 > Y1 then
            Left := True;
        elsif Y2 < Y1 then
            Right := True;
        else
            Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
            Ekran.Pisz_XY(1,16, "Nie mozesz skoczyc do gory");
            MovePawn(Board);
        end if;
         
        if Board(X2, Y2) /= 0 then
            Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
            Ekran.Pisz_XY(1,16, "To miejsce jest zajete");
            MovePawn(Board);
        elsif X2 <= X1 then
            Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
            Ekran.Pisz_XY(1,16, "Mozesz poruszac sie tylko do przodu");
            MovePawn(Board);
        elsif ((X2 - X1) = 1) and ((Y2 - Y1) /= 1) and ((Y1 - Y2) /= 1) then
            Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
            Ekran.Pisz_XY(1,16, "Mozesz przesunac sie tylko o jedno pole");
            MovePawn(Board);
        elsif ((X2 - X1) mod 2 = 1) and ((X2 - X1) /= 1) then
            Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
            Ekran.Pisz_XY(1,16, "Nie mozesz wykonac takiego skoku");
            MovePawn(Board);
        elsif (X2 - X1) mod 2 = 0 then
            if (X2 - X1) /= abs(Y2 - Y1) then
               Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
               Ekran.Pisz_XY(1,16, "Mozesz skakac tylko w jednym kierunku");
               MovePawn(Board);
            end if;
            if Left then
               for I in Integer range 1 .. ((Y2 - Y1)/2) loop
                  if Board(X1 + 2*I - 1, Y1 + 2*I - 1) = 0 then
                     Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
                     Ekran.Pisz_XY(1,16, "Brakuje pionka na drodze skoku");
                     ExitLoop := True;
                  end if;
                  exit when ExitLoop = True;
               end loop;
               if (X2 - X1) > 2 then
                  for I in Integer range 1 .. ((Y2 - Y1)/2 - 1) loop
                     if Board(X1 + 2*I, Y1 + 2*I) /= 0 then
                        Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
                        Ekran.Pisz_XY(1,16, "Pole miedzy pionkami musi byc puste");
                        ExitLoop := True;
                     end if;
                     exit when ExitLoop = True;
                  end loop;
               end if;
               Move := True;
            elsif Right then
               for I in Integer range 1 .. ((Y1 - Y2)/2) loop
                  if Board(X1 + 2*I - 1, Y1 - 2*I + 1) = 0 then
                     Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
                     Ekran.Pisz_XY(1,16, "Brakuje pionka na drodze skoku");
                     ExitLoop := True;
                  end if;
                  exit when ExitLoop = True;
               end loop;
               if (X2 - X1) > 2 then
                  for I in Integer range 1 .. ((Y1 - Y2)/2 - 1) loop
                     if Board(X1 + 2*I, Y1 - 2*I) /= 0 then
                        Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
                        Ekran.Pisz_XY(1,16, "Pole miedzy pionkami musi byc puste");
                        ExitLoop := True;
                     end if;
                     exit when ExitLoop = True;
                  end loop;
               end if;
               Move := True;
            end if;
        else
            Move := True;
        end if;
    end if;
      
    if ExitLoop = True then
        Move := False;
        MovePawn(Board);
    end if;
    
    if Move = True then
        -- moving pawns
        PawnVal := Board(X1, Y1);
        GoalVal := Board(X2, Y2);
        Board(X1, Y1) := GoalVal;
        Board(X2, Y2) := PawnVal;
    end if;
      
    Ekran.Pisz_XY(1,16, 50*' ', Atryb=>Czysty);
  end MovePawn;
   
  function CheckIfEnd(Board : in out Array2DType) return Boolean is
    -- checking if game is finished
  begin
    --
    if Board(6,1) = 2 and Board(6,3) = 2 and Board(6,5) = 2 and Board(6,7) = 2 and Board(7,0) = 2 and Board(7,2) = 2 and Board(7,4) = 2 and Board(7,6) = 2 then
         return True;
    else
         return False;
    end if;
  end CheckIfEnd;

  task body Kontrol is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    -- board init
    Board : Array2DType := (0 => (0, 2, 0, 2, 0, 2, 0, 2),
                            1 => (2, 0, 2, 0, 2, 0, 2, 0),
                            6 => (0, 1, 0, 1, 0, 1, 0, 1),
                            7 => (1, 0, 1, 0, 1, 0, 1, 0),
                            others => (0, 0, 0, 0, 0, 0, 0, 0));
  begin
    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    --Address.Addr := Addresses (Get_Host_By_Address(Inet_Addr("10.0.0.1")),1);
    --Address.Addr := Inet_Addr("10.0.0.1");
    --Address.Addr := Addresses (Get_Host_By_Name ("imac.local"), 1);
    --Address.Addr := Addresses (Get_Host_By_Name ("localhost"), 1);
    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port = ("&Image(Address)&")");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);
    Put_Line ( "Kontroler: czekam na Sensor ....");
    Accept_Socket (Server, Socket, Address);
    Channel := Stream (Socket);
    Ekran.Tlo;
    ArrayToStrPrint(3,4, Board);
    loop
      -- get board prom player2 and print
      Board := Array2DType'Input(Channel);
      ArrayToStrPrint(3,4, Board);
      -- move pawn and print
      MovePawn(Board);
      ArrayToStrPrint(3,4, Board);
      -- checking if game is finished after move and clearing board if needed
      if CheckIfEnd(Board) then 
            Ekran.Pisz_XY(1,16, "Wygrales!");
            Board := (0 => (0, 2, 0, 2, 0, 2, 0, 2),
                      1 => (2, 0, 2, 0, 2, 0, 2, 0),
                      6 => (0, 1, 0, 1, 0, 1, 0, 1),
                      7 => (1, 0, 1, 0, 1, 0, 1, 0),
                      others => (0, 0, 0, 0, 0, 0, 0, 0));
            -- waiting 5s to print new cleared board
            delay 5.0;
            ArrayToStrPrint(3,4, Board);
      end if;
      
      --  send board to player1
      Array2DType'Output (Channel, Board);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Kontrol");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Kontrol;

end Player1_Pak;
