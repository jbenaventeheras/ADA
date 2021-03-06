with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Hash_Maps_G;
with Ada.Strings.Maps;




package body Handlers is


   package CM renames Chat_Messages;
	use type CM.Message_Type;
	use type CM.Seq_N_T;
    use type Ada.Calendar.Time;

------Funciones y procedimientos que utilizaremos en handler en este caso solo en el handler_server
  
	 function Hash (US: ASU.Unbounded_String) return Hash_Range is

      Suma : integer :=0;
      
      begin
    
        For I in 1..ASU.Length(US) loop
        Suma := Suma + Character'Pos(ASU.Element(US,I));
	     end loop;

      return Hash_Range'Mod(Suma);
   end Hash;

   
	function Cut_IP (C:  LLU.End_Point_Type) return  ASU.Unbounded_String is
	   
	   Client_EP:  LLU.End_Point_Type ;
	   Client_IP:  ASU.Unbounded_String ;
	   Client_PT:  ASU.Unbounded_String ;
	   Line:       ASU.Unbounded_String ;
	   Position: integer;
	   
	begin
	  LLU.Bind_Any(Client_EP) ;
	  Line:= ASU.To_Unbounded_String (LLU.Image(Client_EP)) ;
	  Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(":"))+1 ;
	  ASU.Tail( Line , ASU.Length(Line) - Position) ;
	  Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(",")) ;
	  Client_IP :=ASU.Head(Line, Position -1) ;
	  Line:= ASU.Tail( Line , ASU.Length(Line) - Position) ;
	  Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(":")) +1  ;
	  Client_PT :=ASU.Tail(Line, Position-2 ) ;
	  return Client_IP;
	end Cut_IP;





   function Time_Image (T: Ada.Calendar.Time) return String is
    begin
      return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
      end Time_Image;

 procedure Print_CA_Map (M : CA_Maps.Map) is
      C: CA_Maps.Cursor := CA_Maps.First(M);
   begin
      Ada.Text_IO.Put_Line ("==============");

      while CA_Maps.Has_Element(C) loop
         Ada.Text_IO.Put_Line (ASU.To_String(CA_Maps.Element(C).Key) & " " &(ASU.To_String(Cut_IP(CA_Maps.Element(C).Value.Client_EP_Handler))) &  " " & Time_Image(CA_Maps.Element(C).Value.Last_mess));
         CA_Maps.Next(C);
      end loop;
   end Print_CA_Map;
     
  procedure Print_CI_Map (M : CI_Maps.Map) is
     C: CI_Maps.Cursor := CI_Maps.First(M);
   begin
      Ada.Text_IO.Put_Line ("==============");

     while CI_Maps.Has_Element(C) loop
      Ada.Text_IO.Put_Line (ASU.To_String(CI_Maps.Element(C).Key) & " " &
                                Time_Image(CI_Maps.Element(C).Value));
         CI_Maps.Next(C);
      end loop;
   end Print_CI_Map;


     ----itero sobre todos los elemetos de una lista enviando a todos menos asi mismo
      procedure Send_To_All_v2 (M: in CA_Maps.Map; P_Buffer: access LLU.Buffer_Type; No_Send_Nick: in ASU.Unbounded_String ) is
           C: CA_Maps.Cursor := CA_Maps.First(M);
	
	begin
	
                   while CA_Maps.Has_Element(C) loop
                                  if ASU.To_String(CA_Maps.Element(C).Key) /= ASU.To_String(No_Send_Nick) then
					LLU.Send (CA_Maps.Element(C).Value.Client_EP_Handler, P_Buffer);
				   end if;
                              CA_Maps.Next(C);
                             end loop;


      end Send_To_All_v2;


    procedure Search_Oldest (M : in CA_Maps.Map; Oldest_client: out ASU.Unbounded_String ) is
      
      C: CA_Maps.Cursor := CA_Maps.First(M);
      Oldest_Last_Mess: Ada.Calendar.Time:= Ada.Calendar.Clock;
     

   begin
      Ada.Text_IO.Put_Line ("==============");
      
      while CA_Maps.Has_Element(C) loop
         if CA_Maps.Element(C).Value.Last_mess < Oldest_Last_Mess then
				         Oldest_client := (CA_Maps.Element(C).key);
                         Oldest_Last_Mess:=CA_Maps.Element(C).Value.Last_mess;
           end if;
			
         CA_Maps.Next(C);

      end loop;

   end Search_Oldest;


-----------
     ----variables para los values de las tablas de simbolos---
      Value_CI : Ada.Calendar.Time;
      Value_CA   :info;
      Success : Boolean;
      Oldest_client: ASU.Unbounded_String;

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------- SERVER HANDLER PARA MANEJAR LA RECEPCIÓN DE MENSAJES AL SERVER MIENTRAS QUE EL PROGRAMA PRINCIPAL QUEDA LIBRE PARA IMPRIMIR LISTAS

   procedure Server_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is


      Client_EP_Handler: LLU.End_Point_Type;
      Client_EP_Recive: LLU.End_Point_Type;
      Comentario  : ASU.Unbounded_String;
      Mess: CM.Message_Type;
      NickName: ASU.Unbounded_String;
      NickName2: ASU.Unbounded_String;
      Cogido: boolean;
      Oldest_client: ASU.Unbounded_String;
      Delete_Success: boolean;


   begin
      -- saca lo recibido en el buffer P_Buffer.all
      Mess := CM.Message_Type'Input (P_Buffer);
	 
	if Mess = CM.Init then 
	      
	      Client_EP_Recive := LLU.End_Point_Type'Input (P_Buffer);
          Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
	      NickName := ASU.Unbounded_String'Input (P_Buffer);
		
	     CA_Maps.Get (CA_Map, NickName, Value_CA, Success);
		--sino se encuentra en la tabla lo añade con un put con el nickname y el value(record), y envia un 
                -- welcome con cogido = true, finalmente envia un server a los demas clientes.
          if not Success then

		          Value_CA.Client_EP_Handler:= Client_EP_Handler;
		          Value_CA.Last_mess := Ada.Calendar.Clock; 
          --- Al hacer put si salta la excepcion deberemos borrar el mas antiguo y volver hacer put, despues continua y envia cogido a True,
          --- ya que ya ha sido comprobado que el nickname no se encuentra.
                   begin 
			         CA_Maps.Put (CA_Map, NickName, Value_CA);
                    exception 
						when CA_Maps.Full_Map  =>
                         -- busca el mas antiguo
                           Search_Oldest(CA_Map, Oldest_client);
                   -------------------------------------------mensaje server que informa a todos incluido el que es baneado del el baneo--------------
								 LLU.Reset (P_Buffer.all);
								 Mess := CM.Server;
								 CM.Message_Type'Output(P_Buffer, Mess);
								 Comentario:= Oldest_client & ASU.To_Unbounded_String(" banned for being idle too long");
								 NickName2 := ASU.To_Unbounded_String("Server");
								 ASU.Unbounded_String'Output(P_Buffer, NickName2);
								 ASU.Unbounded_String'Output(P_Buffer, Comentario);
								 Send_To_All_v2 (CA_Map, P_Buffer, ASU.To_Unbounded_String("**IMPOSSIBLENICK**")); 
                         ------despues de enviarle incluido a si mismo el server con el baneo borramos el mas antiguo
                                 CA_Maps.Delete (CA_Map,Oldest_client, Delete_Success);
                         ----como ya hemos borrado al mas antiguo llamamos a Put de nuevo con el cliente que no pudo entrar por el Full_Map
                                 CA_Maps.Put (CA_Map, NickName, Value_CA);
			              if Delete_Success then 
                            Ada.Text_IO.Put_Line (  ASU.To_String(Oldest_client) &    " banned for being idle too long");
                            CI_Maps.Put (CI_Map, Oldest_client,  Ada.Calendar.Clock);
                              
                           end if;

					end;
				  Ada.Text_IO.Put_Line ("INIT recived from :" & ASU.To_String(NickName) & ". ACCEPTED");

			 -- reinicializa (vacía) el buffer P_Buffer.all
			  LLU.Reset (P_Buffer.all);
			  -- introduce Mensaje Welcome
		          Mess := CM.Welcome;
			      CM.Message_Type'Output(P_Buffer, Mess);
			      Cogido := True;     
			      boolean'Output (P_Buffer, Cogido);
			-- envía el contenido del Buffer P_Buffer.all
			   LLU.Send (Client_EP_Recive, P_Buffer);
			 ---mensaje server
			 LLU.Reset (P_Buffer.all);
		     Mess := CM.Server;
		     CM.Message_Type'Output(P_Buffer, Mess);
			 Comentario:= NickName & ASU.To_Unbounded_String(" Joins the Chat");
			 NickName2 := ASU.To_Unbounded_String("Server: ");
			 ASU.Unbounded_String'Output(P_Buffer, NickName2);
		     ASU.Unbounded_String'Output(P_Buffer, Comentario);
		     Send_To_All_v2 (CA_Map, P_Buffer, NickName);               


	      else
		--si esta el nickname lo ignora y envia un welcome con cogido =false
		       Ada.Text_IO.Put_Line ("INIT recived from :" & ASU.To_String(NickName) & ". IGNORED, nick already used");
               LLU.Reset (P_Buffer.all);
	       -- introduce Mensaje Welcome
              Mess := CM.Welcome;
	          CM.Message_Type'Output(P_Buffer, Mess);
	          Cogido := False;     
	          boolean'Output (P_Buffer, Cogido);
	      -- envía el contenido del Buffer P_Buffer.all
	          LLU.Send (Client_EP_Recive, P_Buffer);

	      end if;

	elsif Mess = CM.Logout then
		-- si es logout comprobará si esta el nickname en la lista y si es asi comparará el end point de la lista sacado en el value con el del cliente sacado del mensaje logout y borrará el cliente, despues lo añadirá a la lista de clientes inactivos por ultimo envia un server a todos los clientes
		    Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
	        NickName := ASU.Unbounded_String'Input (P_Buffer);
	         CA_Maps.Get (CA_Map, NickName, Value_CA, Success);
           if Success then 
			 if Value_CA.Client_EP_Handler = Client_EP_Handler then
				    CA_Maps.Delete (CA_Map,NickName, Success);
				    Ada.Text_IO.Put_Line ("Logout recived from : " & ASU.To_String(NickName));
                    Value_CI := Ada.Calendar.Clock;
                   CI_Maps.Put (CI_Map, NickName, Value_CI);
			 ---mensaje server------
				     LLU.Reset (P_Buffer.all);
                     Mess := CM.Server;
                     CM.Message_Type'Output(P_Buffer, Mess);
				     Comentario:= NickName & ASU.To_Unbounded_String(" Leaves the chat");
				     NickName2 := ASU.To_Unbounded_String("Server: ");
				     ASU.Unbounded_String'Output(P_Buffer, NickName2);
                     ASU.Unbounded_String'Output(P_Buffer, Comentario);
                     Send_To_All_v2 (CA_Map, P_Buffer, NickName);
			 end if;
	      end if;

	elsif Mess = CM.Writer then
		Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
		NickName := ASU.Unbounded_String'Input (P_Buffer);
		Comentario := ASU.Unbounded_String'Input (P_Buffer);
		CA_Maps.Get (CA_Map, NickName, Value_CA, Success);
           if Success then 
			  if value_CA.Client_EP_Handler = Client_EP_Handler then
				Ada.Text_IO.Put_Line ("Writer recived from " & ASU.To_String(NickName) & ": " & ASU.To_String(Comentario));
			      --actualizamos value para actualizar la hora.
				            Value_CA.Client_EP_Handler:= Client_EP_Handler;
              		        Value_CA.Last_mess := Ada.Calendar.Clock;
	                        CA_Maps.Put (CA_Map, NickName, Value_CA);
				--Construye el mensaje Server
                            LLU.Reset (P_Buffer.all);
                            Mess := CM.Server;
                            CM.Message_Type'Output(P_Buffer, Mess);
				            ASU.Unbounded_String'Output(P_Buffer, NickName);
                            ASU.Unbounded_String'Output(P_Buffer, Comentario);
				--reenvia con el send all, a todos menos al que lo ha enviado
                            Send_To_All_v2 (CA_Map, P_Buffer, NickName );
				

			   end if;
	        end if;
	     
	end if;


   end Server_Handler;

--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------  ----------CLIENT HANDLER UTILIZADO PARA RECIBIR MENSAJES SERVER MIENTRAS PODEMOS ENVIAR MENSAJES WRITER ---------------------


   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
      
      Mess : CM.Message_Type;
      NickName: ASU.Unbounded_String;
      Comentario: ASU.Unbounded_String;
   begin
         ----Sacamos Mensaje server que envía un servidor a un cliente con el comentario que le llegó en un mensaje Writer 
       Mess := CM.Message_Type'Input (P_Buffer);
	if Mess = CM.Server then
        NickName := ASU.Unbounded_String'Input(P_Buffer);
	    Comentario := ASU.Unbounded_String'Input(P_Buffer);
	    Ada.Text_IO.Put_Line( ASU.To_String(NickName) & ": " & ASU.To_String(Comentario));
        Ada.Text_IO.Put_Line(">>");
        
		end if;
 


   end Client_Handler;


end Handlers;
