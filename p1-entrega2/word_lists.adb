package body word_lists is

 procedure Free is new
  Ada.Unchecked_Deallocation
   (Cell, Word_List_Type);
 

 procedure Add_Word (List: in out Word_List_Type;
                  Word: in ASU.Unbounded_String) is

	  P_Aux : Word_List_Type;
	  P_Prev: Word_List_Type;
      Found : Boolean;
   begin

      P_Aux := List;
      Found := False;
  --si lista vacia la creamos
 	if List = null then
		List:= new Cell'(Word, 1,null);
  --si esta la palabra sumamos uno 
	else
      while not Found and P_Aux /= null loop
         if P_Aux.Word = Word then
            P_Aux.Count := P_Aux.Count + 1;
            Found := True;
         end if;
		 P_Prev:= P_Aux;
         P_Aux := P_Aux.Next;

      end loop;

      -- Si no esta añadimos al final
      if not Found then
         P_Aux:= new Cell'(Word, 1,null);
		 P_Prev.next:= P_Aux;
         
      end if;
	end if;
 end Add_Word;


 procedure Print_All (List: in Word_List_Type) is

		 P_Aux : Word_List_Type;

	begin
		P_Aux := List;
		while P_Aux /= null loop
            Ada.Text_IO.Put_Line("|"& ASU.To_String(P_Aux.Word)&"|" &"-"& (Integer'Image(P_Aux.Count)));
			P_Aux := P_Aux.Next;
		end loop;

  end Print_All;


 procedure Delete_Word (List: in out Word_List_Type;
                  Word: in ASU.Unbounded_String) is


      P_Aux  : Word_List_Type;
      P_Prev : Word_List_Type;
      found: boolean;
   	  
  begin
   
          P_Aux:= List;
	  P_Prev:= P_Aux;	
	  found := False;
       while not Found and P_Aux /= null loop		
  		-- si encuenta la palabra y no es la primera libera con Aux y enlaza con Prev
		if P_Aux.Word = Word and P_Aux /= list then
		   P_Prev.Next :=P_Aux.Next;
		   Ada.Text_IO.Put_Line("Word |" & ASU.To_String(P_Aux.Word) & "| deleted");
                   Free(P_Aux);
	           P_Aux := P_Prev.Next;
                   Found := True;
		  --si es la primera palabra cambia list a la segunda y libera con Aux
		elsif P_Aux.Word = Word and P_Aux = list then
	           list:= P_Aux.next;
                   Ada.Text_IO.Put_Line("Word |" & ASU.To_String(P_Aux.Word) & "| deleted");
	           Free(P_Aux);
		   Found := True;
		  -- si no encuentra sigue avanzando Prev sigue Aux
		else
		   P_Prev:= P_Aux;
		   P_Aux := P_Aux.Next;		
         	end if;
	 end loop;

 end Delete_Word;


 procedure Search_Word (List: in Word_List_Type;
		          Word: in ASU.Unbounded_String;
			            Count: out Natural) is

	 P_Aux  : Word_List_Type;
	 Found: boolean;
	 Palabra: ASU.Unbounded_String;	
	
 begin

	  P_Aux:= List;
	  found := False;
       while not Found and P_Aux /= null loop		
          if P_Aux.Word = Word then
		   Palabra:= P_Aux.Word;
		   Count:= P_Aux.Count;
		   found := true;
		   Ada.Text_IO.Put_Line ( "|"& ASU.To_String(Palabra) & "|"& "-" & Natural'Image(Count));
	  else 
		   P_Aux := P_Aux.Next;	
          end if;
	end loop;
	
	if found = false then
          Ada.Text_IO.Put_Line ( "La palabra no se encuentra en la lista");
	end if;

 end Search_Word;


 procedure Max_Word (List: in Word_List_Type;
	                    Word: out ASU.Unbounded_String;
		                 Count: out Natural) is
        
         P_Aux  : Word_List_Type;
  begin

	  P_Aux:= List;
 	  count:= P_Aux.Count;
	  Word:=  P_Aux.Word;	
       while P_Aux /= null loop		
             if Count < P_Aux.Count then
		count:= P_Aux.Count;
		Word:=  P_Aux.Word;
	else 	
       		 P_Aux := P_Aux.Next;
	     end if;
      
	end loop;
        
     Ada.Text_IO.Put_Line ("The most frequent word: " & "|"& ASU.To_String(Word) & "|"& "-" & Natural'Image(Count));
        

 end Max_word;

end word_lists;
