-- Rejurhf
-- 4.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;
use Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;

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
    -- moving Pawns
    -- Input of Pawn and Goal in string
    Pawn,Goal : String (1..10);
    -- Positions from where and where to move Pawn
    X1,X2,Y1,Y2 : Integer;
    -- values of positions
    PawnVal, GoalVal : Integer;
  begin
    -- clean before input
    Ekran.Pisz_XY(1,13, 20*' ', Atryb=>Czysty);
    Ekran.Pisz_XY(1,14, 20*' ', Atryb=>Czysty);
    Pawn := GetInput(13);
    Goal := GetInput(14);
    -- convert input to integers
    X1 := ConvertToPos(Pawn(2));
    Y1 := ConvertToPos(Pawn(1));
    X2 := ConvertToPos(Goal(2));
    Y2 := ConvertToPos(Goal(1));

    -- moving pawns
    PawnVal := Board(X1, Y1);
    GoalVal := Board(X2, Y2);
    Board(X1, Y1) := GoalVal;
    Board(X2, Y2) := PawnVal;
  end MovePawn;

  task body Kontrol is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    -- board init
    Board : Array2DType :=
                        (0 => (0, 2, 0, 2, 0, 2, 0, 2),
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
      --  send board to player1
      Array2DType'Output (Channel, Board);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Kontrol");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Kontrol;

end Player1_Pak;
