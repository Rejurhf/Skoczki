-- Rejurhf
-- 12.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar;
use  Ada.Text_IO, Ada.Exceptions, GNAT.Sockets, Ada.Calendar;

package body Sensor_Pak is
  Czekaj : Boolean := False;

  task Connection is
    entry Start;
    entry Send(Dane : Integer);
    entry Receive(Dane : in out Integer);
  end Connection;

  task body Connection is
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
  begin
    accept Start;
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
      Channel := Stream (Socket);
      select
        accept Send(Dane : Integer) do
          Integer'Output (Channel, Dane);
          Czekaj := True;
        end Send;
        or
        accept Receive(Dane : in out Integer) do
          Dane := Integer'Input (Channel);
          Czekaj := False;
        end Receive;
      end select;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Connection;

  task body Sens is
    Nastepny : Time;
    Okres   : constant Duration := 1.2;
    Dane     : Integer := 0;
  begin
    Nastepny := Clock;
    Connection.Start;
    loop
      Put_Line("Sensor: czekam okres ...");
      delay until Nastepny;

      --  Send message to kontroler
      Put_Line("Sensor: -> wysyłam dane ...");
      Dane := Dane + 2;
      Connection.Send(Dane);
      --  Receive and print message from Kontroler
      Connection.Receive(Dane);
      while Czekaj loop
        delay 0.5;
      end loop;
      -- Dane := Integer'Input (Channel);

      Put_Line ("Sensor: <-" & Dane'Img);
      Nastepny := Nastepny + Okres;
    end loop;
  end Sens;

end Sensor_Pak;
