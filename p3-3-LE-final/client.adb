with Handlers;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;

procedure Client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package CL renames Ada.Command_Line;
	  	package CM renames Chat_Messages;
		 use type CM.Message_Type; 
  
   Server_EP: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Client_EP_Recive: LLU.End_Point_Type;
   Buffer   : aliased LLU.Buffer_Type(1024);
   Request  : ASU.Unbounded_String;
   NickName: ASU.Unbounded_String;
   Comentario: ASU.Unbounded_String;
   Mess : CM.Message_Type;
   Expired : Boolean;
   Salir: Boolean;
   Acogido : Boolean;
   quit: exception;

begin
	
	NickName:= (ASU.To_Unbounded_String(CL.Argument(3)));
   
	   -- Construye el End_Point en el que está atado el servidor
   Server_EP := LLU.Build(LLU.To_IP(CL.Argument(1)), Integer'Value (CL.Argument(2)));  
  
 -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Client_EP_Recive);


   -- Construye un End_Point libre cualquiera y se ata a él con un handler
   LLU.Bind_Any (Client_EP_Handler, Handlers.Client_Handler'Access);

	   -- reinicializa el buffer para empezar a utilizarlo
   LLU.Reset(Buffer);

		-------mensaje INIT -----------------
	Mess := CM.Init;
	CM.Message_Type'Output(Buffer'Access, Mess);

    -- introduce el End_Point_Recive del cliente en el Buffer donde recibe el Welcome                                                                  
    LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Recive);
    
     --end donde recibe los server
     LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);

	
	--introduce el nick para enviarselo al servidor
	   ASU.Unbounded_String'Output(Buffer'Access, NickName);
	
	-- envía el contenido del Buffer
   LLU.Send(Server_EP, Buffer'Access);
	----enviado el mensaje INIT-----------------

  LLU.Reset(Buffer);

   Salir:= False;
	while not Salir loop
   -- espera 10.0 segundos a recibir algo dirigido al Client_EP_Recive
   --   . si llega antes, los datos recibidos van al Buffer
   --     y Expired queda a False
   --   . si pasados los 2.0 segundos no ha llegado nada, se abandona la
   --     espera y Expired queda a True
   LLU.Receive(Client_EP_Recive, Buffer'Access, 10.0, Expired);
   if Expired then
      Ada.Text_IO.Put_Line ("server unrechable");
      Salir:= True;
   else
	
      -- saca del Buffer el mensaje welcome.
	Mess:= CM.Message_Type'Input(Buffer'Access);
	Acogido := boolean'Input(Buffer'Access);
	if Acogido then
	Ada.Text_IO.Put_Line ("Mini-Chat v2.0: Welcome " & ASU.To_String(NickName));
    Ada.Text_IO.Put_line(">>");

	

				loop 

                         LLU.Reset(Buffer);

			-------mensaje WRITER -----------------
			Mess := CM.Writer;
			CM.Message_Type'Output(Buffer'Access, Mess); 	
			
			LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);

			ASU.Unbounded_String'Output(Buffer'Access, NickName);
		
		   	Ada.Text_IO.Put(">>");
		   	Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			ASU.Unbounded_String'Output(Buffer'Access, Comentario);
				-- Si es .quit no llega a enviar el writer sino que envia un logoout.
			if ASU.To_String(Comentario) = ".quit" then
                                   
                                 LLU.Reset(Buffer); 
				-- Enviamos Mensaje Logout antes de cerrar sesion en cliente
				Mess := CM.Logout;
				CM.Message_Type'Output(Buffer'Access, Mess); 		
                LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
				ASU.Unbounded_String'Output(Buffer'Access, NickName);	
				 LLU.Send(Server_EP, Buffer'Access);
			        
				raise quit;

			   end if;
                       Ada.Text_IO.Put_Line(">>");
                       --envia Writer
                         LLU.Send(Server_EP, Buffer'Access); 
  
		end loop;

	else 
		Salir:= True;	
		Ada.Text_IO.Put_Line (ASU.To_String(NickName) & (" : nick already used"));	
        LLU.Finalize;
      
   end if;

 end if;
	end loop;

   LLU.Finalize;

exception
   when quit =>
	Ada.Text_IO.Put_Line ("sesion cliente cerrada");
	   LLU.Finalize;

    when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Client;
