with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;

package body Hash_Maps_G is


  package ASU renames Ada.Strings.Unbounded;

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
  --pos es una variable tipo hash_range que almacena el indice que corresponde al key que se le ha pasado convertida por funcion hash
      pos : hash_range:=hash(key);
      
  
   begin
       --Como hemos definido el Indice del array como tipo Hash_range, podemos colocar pos como Indice.
      P_Aux := M.P_Array(pos);
      Success := False;
      

      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;



   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is

      P_Prev : Cell_A;
      P_Aux : Cell_A;
      Found : Boolean;
      pos : hash_range:=hash(key); 

   begin

   
      -- Si ya existe Key, cambiamos su Value

      P_Aux := M.P_Array(pos);
      P_Prev:= P_Aux;
      --SI LISTA VACIA LA CREA ----------------COMO CADA INDICE TIENE UNA LISTA DEBERÁ COMPROBAR SI SE HA LLEGADO AL MÁX, YA QUE 
      -- SE PODRIA HABER ALCANZADO CON LISTAS DE OTROS INDICES Y QUE LA LISTA DE ESTE INDICE AUN NO HUBIESE SIDO CREADA.
    if P_Aux = null and M.length < Max then
          P_Aux := new Cell'(Key, Value, null);	
          M.P_Array(pos) := P_Aux;
		  M.Length := M.Length + 1;
	else
    ---SI LA ENCUENTRA ACTUALIZA SU VALOR
      Found := False;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
         end if;
          P_Prev:= P_Aux;
          P_Aux := P_Aux.Next;
      end loop;

      -- Si no hemos encontrado Key añadimos al final.
      if not Found and M.length < Max then
         P_Aux := new Cell'(Key, Value, null);
         P_Prev.Next := P_Aux;
         M.Length := M.Length + 1;
        
	  elsif not Found and M.length = Max then
			raise Full_Map; 
      end if;
    end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is

      P_Current  : Cell_A;
      P_Previous : Cell_A;
      pos : hash_range:=hash(key); 

   begin
      Success := False;
      P_Previous := null;
      P_Current  := M.P_Array(pos);
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Previous /= null then
               P_Previous.Next := P_Current.Next;
            end if;
            if M.P_Array(pos) = P_Current then
               M.P_Array(pos) := M.P_Array(pos).Next;
            end if;
            Free (P_Current);
         else
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;


	
	
	-------------------------FIRST-------------------------
	function First (M: Map) return Cursor is
		I: Natural := 0;
	begin
		while Hash_Range'Mod(I) < Hash_Range'Last and M.P_Array(Hash_Range'Mod(I)) = null loop
			I := I + 1;
		end loop;
		
		return (M => M, Index_Array => Hash_Range'Mod(I), Element_A => M.P_Array(Hash_Range'Mod(I)));

	end First;
	
	
	
	-------------------------NEXT-------------------------
	procedure Next (C: in out Cursor) is
		Found: Boolean:= False;
	begin
		while not Found loop
			if C.Element_A/= null and then C.Element_A.Next /= null then
				C.Element_A:= C.Element_A.Next;
				Found := True;
			else
				C.Index_Array := C.Index_Array + 1;
				if C.Index_Array = 0 then
					Found := True;
					C.Element_A := null;
				else
					C.Element_A := C.M.P_Array (C.Index_Array);
					if C.Element_A /= null then
						Found := True;
					end if;
				end if;
			end if;
		end loop;		

	end Next;

   function Element (C: Cursor) return Element_Type is
   begin
      if C.Element_A /= null then
         return (Key   => C.Element_A.Key,
                 Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;

   function Has_Element (C: Cursor) return Boolean is
   begin
      if C.Element_A /= null then
         return True;
      else
         return False;
      end if;
   end Has_Element;

  

   


end Hash_Maps_G;
