with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_line;
with Chat_Messages;
with client_collections;

procedure chat_client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package CL renames Ada.Command_line;
   use type ASU.Unbounded_String;
   package CM renames Chat_Messages;
		 use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request:   ASU.Unbounded_String;
   Reply:      ASU.Unbounded_String;
   Expired : Boolean;
   Salir : Boolean;
   Opcion:     ASU.Unbounded_String;
   Mess: CM.Message_Type;
   NickName: ASU.Unbounded_String;

begin


	   NickName:= (ASU.To_Unbounded_String(CL.Argument(3)));
	  -- Construye el End_Point en el que está atado el servidor
           Server_EP := LLU.Build(LLU.To_IP(CL.Argument(1)), Integer'Value (CL.Argument(2)));
	   -- Construye un End_Point libre cualquiera y se ata a él
           LLU.Bind_Any(Client_EP);

		if NickName = "reader" then
					
	
		  -- reinicializa el buffer para empezar a utilizarlo
		   LLU.Reset(Buffer);
                  -----INIT DEL READER----
                   Mess := CM.Init;
                   CM.Message_Type'Output(Buffer'Access, Mess);

				   -- introduce el End_Point del cliente en el Buffer
				   -- para que el servidor sepa dónde responder
				   LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
				   -- introduce el nickname
 			       ASU.Unbounded_String'Output(Buffer'Access, NickName);

				  LLU.Send(Server_EP, Buffer'Access);

				   -- reinicializa (vacía) el buffer para ahora recibir en él
				   LLU.Reset(Buffer);
		
					loop
				 	 LLU.Receive(Client_EP, Buffer'Access, 1000.0, Expired);
					   if Expired then
						  Ada.Text_IO.Put_Line ("Plazo expirado");
					   else
						  -- saca SERVER  
						  Mess := CM.Message_type'Input(Buffer'Access);
						  NickName := ASU.Unbounded_String'Input(Buffer'Access);
						  Reply := ASU.Unbounded_String'Input(Buffer'Access);
			              Ada.Text_IO.Put_Line (  ASU.To_String(NickName) & ": " & ASU.To_String(Reply));
						  LLU.Reset(Buffer);
					   end if;

					end loop;

                 -- termina Lower_Layer_UDP
                  LLU.Finalize;

			elsif NickName /= "reader" then
	
				   -- reinicializa el buffer para empezar a utilizarlo
				   LLU.Reset(Buffer);
                   Mess := CM.Init;
                   CM.Message_Type'Output(Buffer'Access, Mess);

				   -- introduce el End_Point del cliente en el Buffer
				   -- para que el servidor sepa dónde responder
				    LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
                    -- introduce el nickname
 			       ASU.Unbounded_String'Output(Buffer'Access, NickName);
                    -- envia INIT
                    LLU.Send(Server_EP, Buffer'Access);

				   -- reinicializa (vacía) el buffer para ahora recibir en él
				   LLU.Reset(Buffer);


				salir := False;
                 while not salir loop 
		  --introduce WRITER y envia hasta .quit		   
	           LLU.Reset(Buffer);
                   Mess := CM.Writer;
                   CM.Message_Type'Output(Buffer'Access, Mess);
		   Ada.Text_IO.Put("Message: ");
                   Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					if Request = ".quit" then
						salir:=True;
					elsif Request /= ".quit" then
                                     LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
				   -- introduce el Mensaje en el Buffer
				   -- (se coloca detrás del End_Point introducido antes)
				   ASU.Unbounded_String'Output(Buffer'Access, Request);
				   -- envía el contenido del Buffer
				   LLU.Send(Server_EP, Buffer'Access);

					end if;


				   -- reinicializa (vacía) el buffer para ahora recibir en él
				   LLU.Reset(Buffer);
				end loop;
-----------------------------------------

		 end if;
LLU.Finalize;



exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end chat_client;
