-- Rejurhf
-- 20.12.2018

with Ada.Text_IO, Ada.Float_Text_IO, Ada.Strings, Ada.Strings.Fixed,
  Ada.Exceptions, Ada.Calendar, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;
use Ada.Text_IO, Ada.Float_Text_IO, Ada.Strings, Ada.Strings.Fixed,
  Ada.Exceptions, Ada.Calendar, Ada.Strings.Unbounded,
  Ada.Text_IO.Unbounded_Io;

procedure Panel is
  Koniec : Boolean := False with Atomic;
  type Array2DType is array (0..7, 0..7) of Integer;

  type Stany is (Duzo, Malo);
  Stan : Stany := Malo with Atomic;

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


  procedure ArrayToStrPrint(X,Y: Positive; Board: Array2DType) is
    -- Print board in console, X,Y are starting points
    Pos: Integer;
  begin
    for i in Integer range 0..7 loop
      Pos := Y;
      for j in Integer range 0..7 loop
        case Board(i,j) is
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
  end ArrayToStrPrint;

  task Przebieg;

  task body Przebieg is
    Nastepny     : Ada.Calendar.Time;
    Okres        : constant Duration := 0.8; -- sekundy
    Przesuniecie : constant Duration := 0.5;
    PrvState     : Stany := Duzo with Atomic;

    Board : Array2DType :=
                        (0 => (0, 2, 0, 2, 0, 2, 0, 2),
                        1 => (2, 0, 2, 0, 2, 0, 2, 0),
                        6 => (0, 1, 0, 1, 0, 1, 0, 1),
                        7 => (1, 0, 1, 0, 1, 0, 1, 0),
                        others => (0, 0, 0, 0, 0, 0, 0, 0));
  begin
    Nastepny := Clock + Przesuniecie;
    loop
      if PrvState /= Stan then
        PrvState := Stan;
        delay until Nastepny;
        if Stan=Duzo then
          Board(1,1) := 1;
        else
          Board(1,1) := 2;
        end if;
        ArrayToStrPrint(3,4, Board);
        Ekran.Pisz_XY(19 ,5, 20*' ', Atryb=>Czysty); -- clean area
        Ekran.Pisz_XY(15 ,13, Stan'Img, Atryb=>Podkreslony);
        Nastepny := Nastepny + Okres;
      end if;
      exit when Koniec;
      delay until Nastepny;
    end loop;
    -- add last empty line, only estetics
    Ekran.Pisz_XY(1,14,"");
    exception
      when E:others =>
        Put_Line("Error: Zadanie Przebieg");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Przebieg;


  Zn : Character;
begin
  -- game loop
  Ekran.Tlo;
  loop
    Get_Immediate(Zn);
    exit when Zn in 'q'|'Q';
    Stan := (if Zn in 'D'|'d' then
      Duzo elsif Zn in 'M'|'m' then Malo else Stan);
  end loop;
  Koniec := True;
end Panel;
