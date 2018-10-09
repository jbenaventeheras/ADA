with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_line;
with Chat_Messages;
with client_collections;
with Ada.Exceptions;
with Ada.Strings.Maps;

procedure chat_server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   use type ASU.Unbounded_String;
   package CL renames Ada.Command_line;
   package CM renames Chat_Messages;
		 use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Admin_EP: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;
   Reply: ASU.Unbounded_String ;
   Maquina : ASU.Unbounded_String:= ASU.To_Unbounded_String (LLU.Get_Host_Name);
   IP: String:= (llU.To_IP(Asu.To_String(Maquina)));
   Expired : Boolean;
   Mess: CM.Message_Type;
   NickName: ASU.Unbounded_String;
   Reader_list: Client_Collections.Collection_Type;
   Writer_list: Client_Collections.Collection_Type;
   finish: Boolean;
   Password_admin : Integer;
   Password : Integer;
   Collection_Unb: ASU.Unbounded_String ;
    
   
 


begin

	Password:= (Integer'value(CL.Argument(2)));
	
   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build (IP, Integer'Value (CL.Argument(1)));

   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP);

   Finish := False;
   while finish = False loop
      -- reinicializa (vacía) el buffer para ahora recibir en él
      LLU.Reset(Buffer);

      -- espera 1000.0 segundos a recibir algo dirigido al Server_EP
      --   . si llega antes, los datos recibidos van al Buffer
      --     y Expired queda a False
      --   . si pasados los 10.0 segundos no ha llegado nada, se abandona
      --     la espera y Expired queda a True
      LLU.Receive (Server_EP, Buffer'Access, 10000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
		     -- saca el tipo de mensaje para ver si es Init o writer
	 Mess := CM.Message_Type'Input (Buffer'Access);
	 if Mess = CM.Init then
	      Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
              NickName := ASU.Unbounded_String'Input (Buffer'Access);
				
		if NickName = "reader" then
            client_collections.Add_Client (Reader_list, Client_EP, NickName, False);
		    Ada.Text_IO.Put_Line ("INIT received from " & ASU.To_String(NickName));
		elsif NickName /= "reader"then
		         begin
              client_collections.Add_Client (Writer_list, Client_EP, NickName, True);
              Ada.Text_IO.Put_Line ("INIT received from " & ASU.To_String(NickName));
			--si no salta expcepcion en el Add_Client envia el server con el Send2All
			  LLU.Reset(Buffer);
              Mess := CM.Server;
              CM.Message_Type'Output(Buffer'Access, Mess);
			  ASU.Unbounded_String'Output(Buffer'Access, NickName);
			  Reply := ASU.To_Unbounded_String("joins the chat");
			  ASU.Unbounded_String'Output(Buffer'Access, Reply);
			  Client_Collections.Send_To_All (Reader_list,Buffer'Access);
                             exception
			       when Client_Collections.Client_Collection_Error =>
                                 Ada.Text_IO.Put_Line ("INIT received from " & ASU.To_String(NickName) & ". IGNORED, nick already used"); 
                         end;
	         end if;
				
		     
	elsif Mess= CM.Writer then
		     Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
             Reply := ASU.Unbounded_String'Input (Buffer'Access); 
			  begin
				NickName:= Client_Collections.Search_Client (Writer_list,Client_EP);
				Ada.Text_IO.Put_Line ("Writer received from " & ASU.To_String(NickName) & ": " & ASU.To_String(Reply));
	        --si no salta la excepcion al buscar el nick envia el server con Send2All
				--Ada.Text_IO.Put_Line (Client_Collections.Collection_Image(Writer_list));
				LLU.Reset(Buffer);
		        Mess := CM.Server;
		        CM.Message_Type'Output(Buffer'Access, Mess);
				ASU.Unbounded_String'Output(Buffer'Access, NickName);
				ASU.Unbounded_String'Output(Buffer'Access, Reply);
				Client_Collections.Send_To_All (Reader_list,Buffer'Access);
                    
		             exception
                               when Client_Collections.Client_Collection_Error  =>
                                  Ada.Text_IO.Put_Line ("WRITER received from unknown client. IGNORED");
					end;



    elsif Mess= CM.Collection_Request then
				Admin_EP := LLU.End_Point_Type'Input (Buffer'Access);
                Password_admin := Integer'Input (Buffer'Access);
					--si el password es correcto envia Collection data con el Unbounded de la coleccion
					if Password_Admin = Password  then
						Ada.Text_IO.Put_Line ("LIST_REQUEST received");
						 LLU.Reset(Buffer);
						 Collection_Unb:= ASU.To_Unbounded_String(Client_Collections.Collection_Image(Writer_list));
						  Mess := CM.Collection_Data;
                          CM.Message_Type'Output(Buffer'Access, Mess);
						  ASU.Unbounded_String'Output(Buffer'Access, Collection_Unb);
						  LLU.Send(Admin_EP, Buffer'Access);
						--Si password incorrecto no envia Collection
                      else
                          Ada.Text_IO.Put_Line ("LIST_REQUEST received .IGNORED, incorrect password"); 
						 
					end if;

	  elsif Mess= CM.Ban then
					Password_admin := Integer'Input (Buffer'Access);
				    ASU.Unbounded_String'Output(Buffer'Access, NickName);
					--si password correcto borra cliente
                    if Password_Admin = Password  then
                        Client_Collections.Delete_Client(Writer_list,NickName);
						Ada.Text_IO.Put_Line ("Ban received for " & ASU.To_String(NickName));
					end if;


	  elsif Mess= CM.Shutdown then
				Password_admin := Integer'Input (Buffer'Access);
				--si password correcto termina el server
				if Password_Admin = Password  then
                      Finish := True;  
					end if;

  
      end if;
     end if;
   end loop;
	
	 LLU.Finalize;
   -- nunca se alcanza este punto
   -- si se alcanzara, habría que llamar a LLU.Finalize;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end chat_server;
