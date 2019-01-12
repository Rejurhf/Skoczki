-- Rejurhf
-- 12.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar;
use  Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar;

package body Sensor_Pak is

  task body Sens is
    Nastepny : Time;
    Okres   : constant Duration := 1.2;
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
    Dane     : Integer := 0;
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
      Put_Line("Sensor: czekam okres ...");
      delay until Nastepny;
      Channel := Stream (Socket);
      --  Send message to kontroler
      Put_Line("Sensor: -> wysyłam dane ...");
      Dane := Dane + 2;
      Integer'Output (Channel, Dane);
      --  Receive and print message from Kontroler
      Dane := Integer'Input (Channel);
      Put_Line ("Sensor: <-" & Dane'Img);
      Nastepny := Nastepny + Okres;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Sens;

end Sensor_Pak;
