-- Rejurhf
-- 3.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar,
  Ada.Float_Text_IO, Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;
use Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar,
  Ada.Float_Text_IO, Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;

package body Sensor_Pak is
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
      Ekran.Pisz_XY(2,3,"8 ");
      Ekran.Pisz_XY(2,4,"7 ");
      Ekran.Pisz_XY(2,5,"6 ");
      Ekran.Pisz_XY(2,6,"5 ");
      Ekran.Pisz_XY(2,7,"4 ");
      Ekran.Pisz_XY(2,8,"3 ");
      Ekran.Pisz_XY(2,9,"2 ");
      Ekran.Pisz_XY(2,10,"1 ");
      Ekran.Pisz_XY(4,11,"A B C D E F G H");
      Ekran.Pisz_XY(1,13,"Q-koniec", Atryb=>Podkreslony);
    end Tlo;
  end Ekran;


  task body Sens is
    Nastepny : Time;
    Okres   : constant Duration := 1.2;
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
    type Array2DType is array (0..7, 0..7) of Integer;
    Board : Array2DType :=
                        (0 => (0, 2, 0, 2, 0, 2, 0, 2),
                        1 => (2, 0, 2, 0, 2, 0, 2, 0),
                        6 => (0, 1, 0, 1, 0, 1, 0, 1),
                        7 => (1, 0, 1, 0, 1, 0, 1, 0),
                        others => (0, 0, 0, 0, 0, 0, 0, 0));
  begin
    Nastepny := Clock;
    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    --Address.Addr := Addresses (Get_Host_By_Address(Inet_Addr("10.0.0.1")),1);
    --Address.Addr := Inet_Addr("10.0.0.1");
    --Address.Addr := Addresses (Get_Host_By_Name ("imac.local"), 1);
    --Address.Addr := Addresses (Get_Host_By_Name ("localhost"), 1);
    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);
    loop
      delay until Nastepny;
      Channel := Stream (Socket);
      --  Send message to kontroler
      Array2DType'Output (Channel, Board);
      --  Receive and print message from Kontroler
      Board := Array2DType'Input(Channel);
      Put_Line ("Sensor: _OK: Board(1,1) <- " & Board(1,1)'Img);
      Nastepny := Nastepny + Okres;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Sens;

end Sensor_Pak;
