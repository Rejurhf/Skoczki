-- Rejurhf
-- 3.01.2019

with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar;
use Ada.Calendar;

package body Sensor_Pak is

  task body Sens is
    Nastepny : Time;
    Okres   : constant Duration := 1.2;
    G       : Generator;
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
    Reset(G);
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
