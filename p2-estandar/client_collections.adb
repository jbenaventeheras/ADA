package body Client_Collections is


	procedure Free is new
  		Ada.Unchecked_Deallocation
  		 (Cell, Cell_A);

 procedure Add_Client (Collection: in out Collection_Type;
                         EP: in LLU.End_Point_Type;
                         Nick: in ASU.Unbounded_String;
                         Unique: in Boolean) is

   P_Aux : Cell_A;
   Found : Boolean;
       
   begin

		 P_Aux := Collection.P_First;
                 Found := False; 
	  --si la lista vacía crea
		if Collection.P_First = null then
		   Collection.P_First:= new Cell'(EP, Nick,null);
                   Collection.Total:= 1;
	  --si unique es false es lista reader y siempre añade 
		elsif  Unique = False then
			P_Aux := new Cell;
            		P_Aux.Client_EP  := EP;
           	 	P_Aux.Nick := Nick;
            		P_Aux.Next  := Collection.P_First;
            		Collection.P_First := P_Aux;
            		Collection.Total:= Collection.Total + 1;
          --si unique es true es lista escritores si lo encuentra eleva expcepcion
		elsif Unique = True then
                   while not Found and P_Aux /= null loop
			 if P_Aux.Nick = Nick  then
				 Raise Client_Collection_Error; 				
                          end if;
		        P_Aux := P_Aux.Next;
                   end loop;
	  --si no lo encuentra añade
	if not Found then
            P_Aux := new Cell;
            P_Aux.Client_EP  := EP;
            P_Aux.Nick := Nick;
            P_Aux.Next  := Collection.P_First;
            Collection.P_First := P_Aux;
            Collection.Total:= Collection.Total + 1;
         
      end if;
	end if;

 end Add_client;


 function Search_Client (Collection: in Collection_Type;
                          EP: in LLU.End_Point_Type)
                           return ASU.Unbounded_String is

   
   P_Aux : Cell_A;
   Found : Boolean;
   NickName: ASU.Unbounded_String; 

   begin
             
         P_Aux := Collection.P_First;
         Found := False; 
		--lo busca y si lo encuentra almacena y deja de buscar	
      while not Found and P_Aux /= null loop
	         if P_Aux.Client_EP = EP  then
		     NickName :=  P_Aux.Nick;
		     found := True;
                  end if;
		     P_Aux := P_Aux.Next;
	end loop;	
                --si no encuentra eleva la excepcion
		  if not found then
				Raise Client_Collection_Error;
		  end if;

      Return NickName;

 end Search_Client;

  procedure Send_To_All (Collection: in Collection_Type;
                      P_Buffer: access LLU.Buffer_Type)is 


      P_Aux : Cell_A;

   begin
             
    P_Aux := Collection.P_First;
			
      while P_Aux /= null loop
	      LLU.Send(P_Aux.Client_EP, P_Buffer);
              P_Aux := P_Aux.Next;

	end loop;

 end Send_To_All;
	
 procedure Delete_Client (Collection: in out Collection_Type;
                        Nick: in ASU.Unbounded_String)is
 


      P_Aux  : Cell_A;
      P_Prev : Cell_A;
      found: boolean;
   	  
  begin
   
          P_Aux := Collection.P_First;
	  P_Prev:= P_Aux;	
	  found := False;
       while not Found and P_Aux /= null loop		
  		-- si encuenta el cliente y no es el primero libera con Aux y enlaza con Prev
		if P_Aux.Nick = Nick and P_Aux /= Collection.P_First then
		   P_Prev.Next :=P_Aux.Next;
		   Ada.Text_IO.Put_Line("Client|" & ASU.To_String(P_Aux.Nick) & "| deleted");
                   Free(P_Aux);
	           P_Aux := P_Prev.Next;
                   Found := True;
		  --si es la primera palabra cambia list a la segunda y libera con Aux
		elsif P_Aux.Nick = Nick and P_Aux = Collection.P_First then
	           Collection.P_First:= P_Aux.next;
                   Ada.Text_IO.Put_Line("Client |" & ASU.To_String(P_Aux.Nick) & "| deleted");
	           Free(P_Aux);
		   Found := True;
		  -- si no encuentra sigue avanzando Prev sigue Aux
		else
		   P_Prev:= P_Aux;
		   P_Aux := P_Aux.Next;		
         	end if;
	 end loop;

 end Delete_Client;


  function Collection_Image  (Collection: in Collection_Type) return String is
	   

	   P_Aux  : Cell_A;
       Total: ASU.Unbounded_String ;
	   Client_EP:  LLU.End_Point_Type ;
	   Client_IP:  ASU.Unbounded_String ;
	   Client_PT:  ASU.Unbounded_String ;
	   NickName: ASU.Unbounded_String ;
	   Line:       ASU.Unbounded_String ;
	   Position: integer;
	   
	begin
	  
	P_Aux := Collection.P_First;
			
      while P_Aux /= null loop
		
		 Client_EP := P_Aux.Client_EP;
         NickName :=  P_Aux.Nick;


	     LLU.Bind_Any(Client_EP) ;
	     Line:= ASU.To_Unbounded_String (LLU.Image(Client_EP)) ;
	     Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(":"))+1 ;
	     ASU.Tail( Line , ASU.Length(Line) - Position) ;
	     Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(",")) ;
	     Client_IP :=ASU.Head(Line, Position -1) ;
	     Line:= ASU.Tail( Line , ASU.Length(Line) - Position) ;
	     Position := ASU.Index(Line,Ada.Strings.Maps.To_Set(":")) +1  ;
	     Client_PT :=ASU.Tail(Line, Position-2 ) ;
	  
		 Total:= ASU.To_Unbounded_String (ASU.To_String(Total) & ASU.To_String(Client_IP) & ":" & ASU.To_String(Client_PT) & " " & ASU.To_String(NickName) &  ASCII.LF);
		 P_Aux := P_Aux.Next;	
	
      end loop;
      
		  Return ASU.To_String(Total);

	end Collection_Image;




end Client_Collections;










