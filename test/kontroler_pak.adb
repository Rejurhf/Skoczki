-- Rejurhf
-- 12.01.2019

with Ada.Text_IO, Ada.Exceptions, GNAT.Sockets;
use  Ada.Text_IO, Ada.Exceptions, GNAT.Sockets;

package body Kontroler_Pak is
  Czekaj : Boolean := False;

  task Connection is
    entry Start;
    entry Send(Dane : Integer);
    entry Receive(Dane : in out Integer);
  end Connection;

  task body Connection is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
  begin
    accept Start;
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
    loop
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
    when E:others => Put_Line("Error: Zadanie Kontrol");
    Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Connection;

  task body Kontrol is
    Dane     : Integer := 0;
  begin
    Connection.Start;
    loop
      -- Dane := Integer'Input (Channel);
      Connection.Receive(Dane);
      while Czekaj loop
        delay 0.5;
      end loop;
      Put_Line ("Kontroler: -> dane =" & Dane'Img);
      --  Komunikat do: Sensor
      Dane := Dane - 1;
      -- Integer'Output (Channel, Dane);
      Connection.Send(Dane);
    end loop;
  end Kontrol;

end Kontroler_Pak;
