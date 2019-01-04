-- Rejurhf
-- 4.01.2019

with System;
with Player1_Pak; pragma Unreferenced(Player1_Pak);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Player1 is
  pragma Priority (System.Priority'First);
begin
  Put_Line("Player1: początek");
  loop
    null;
  end loop;
end Player1;
