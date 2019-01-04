-- Rejurhf
-- 3.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;
use Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Float_Text_IO,
  Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;

package body Kontroler_Pak is
  type Array2DType is array (0..7, 0..7) of Integer;
  type Atrybuty is (Czysty, Jasny, Podkreslony, Negatyw, Migajacy, Szary);

  protected Ekran  is
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
      Ekran.Pisz_XY(1,13,"Q-koniec", Atryb=>Podkreslony);
    end Tlo;
  end Ekran;

  procedure ArrayToStrPrint(X,Y: Positive; Board: Array2DType) is
    -- Print board in console, X,Y are starting points
    Pos: Integer;
  begin
    for i in Integer range 0..7 loop
      Pos := Y;
      for j in Integer range 0..7 loop
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

  task body Kontrol is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
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
    loop
      Board := Array2DType'Input(Channel);
      ArrayToStrPrint(3,4, Board);
      -- Put_Line ("Kontroler: -> Board(1,1) =" & Board(1,1)'Img);
      --  Komunikat do: Sensor
      Board(1,1) := Board(1,1) + 1;
      Array2DType'Output (Channel, Board);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Kontrol");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Kontrol;

end Kontroler_Pak;
