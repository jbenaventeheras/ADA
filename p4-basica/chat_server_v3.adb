with Lower_Layer_UDP;
with Handlers;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
With Chat_Messages;
with Hash_Maps_G;


procedure Chat_Server_v3 is
   
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;
   package CL renames Ada.Command_line;


   Server_EP: LLU.End_Point_Type;
   C: Character;
   Maquina : ASU.Unbounded_String:= ASU.To_Unbounded_String (LLU.Get_Host_Name);
   IP: String:= (llU.To_IP(Asu.To_String(Maquina)));
   Usage_Error: exception;

begin
       if CL.Argument_Count /= 2 then
		raise Usage_Error;
	end if;
   
   Server_EP := LLU.Build (IP, Integer'Value (CL.Argument(1)));


   -- Se ata al End_Point para poder recibir en él con un handler/manejador.
   -- Tras llamar a Bind ya se pueden estar recibiendo mensajes automáticamente
   -- en el manejador
   LLU.Bind (Server_EP, Handlers.Server_Handler'Access);

   -- A la vez que se están recibiendo mensajes en el manejador se
   -- siguen ejecutando las siguientes sentencias en el programa principal

   --- lo utilizaremos para imprimir las listas,(print_all)
        loop
      Ada.Text_IO.Get_Immediate (C);
      if C = 'L' or C = 'l' then
         if Handlers.CA_Maps.Has_Element(Handlers.CA_Maps.First(Handlers.CA_Map)) then
          Ada.Text_IO.Put_Line( "ACTIVE CLIENTS");
          Handlers.Print_CA_Map(Handlers.CA_Map);
         else
	  Ada.Text_IO.Put_Line("LISTA CLIENTES ACTIVOS VACÍA"); 
	 end if;
      elsif C = 'O' or C = 'o' then
         if Handlers.CI_Maps.Has_Element(Handlers.CI_Maps.First(Handlers.CI_Map)) then
          Ada.Text_IO.Put_Line( "OLD CLIENTS");
	  Handlers.Print_CI_Map(Handlers.CI_Map);
	 else
	  Ada.Text_IO.Put_Line("LISTA CLIENTES ANTIGUOS VACÍA"); 
         end if;
      end if;
   end loop;

    

exception


   when Usage_Error =>
		Ada.Text_IO.Put_Line("Usage: <NUMERO DE PUERTO> <MAX>");
		LLU.Finalize;


   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

   
end Chat_Server_v3;
