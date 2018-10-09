with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Unchecked_Deallocation;

package body Ordered_Maps_G is


 --FUNCION QUE CALCULA LA POSICIÓN EN EL ARRAY DE UNA Key_type, EN ESTE CASO UN NICK(Unbounded_String), como definimos en la llamada 
 --al paquete en el handler.ads
	function Pos_Array (M: Map; Key: Key_Type) return Integer is
		Pos: Integer;
		First: Integer:=0;
		Last: Integer:= M.Length - 1;
	begin

		if M.Length = 0 then
			return First;
		end if;
				
		if M.P_Array(First).Key < Key then
			return M.Length; 
		end if;
		
		if Key < M.P_Array(First).Key then
			return First;
		end if;
		
		while First/= Last loop
			Pos:= First + ((Last - First) / 2);--BUSQUEDA BIN
			if M.P_Array(Pos).Key < Key then --avanzamos la first cuando la key sea mayor que la de esa pos.
                                                         --cuando avanzamos del todo first=last
				First:= Pos + 1;
			else
				Last:= Pos;
			end if;
		end loop;
		return First;
			

	end Pos_Array; 	
	


	procedure Get (M		: Map;
				   Key		: in Key_Type;
				   Value	: out Value_Type;
				   Success	: out Boolean) is

		Pos: Natural;

	begin
		Success := False;
		Pos:= Pos_Array(M, Key);
		if M.P_Array(Pos).Key = Key then
			Value:= M.P_Array(Pos).Value;
			Success:= True;
		end if;
			
	end Get;


	procedure Put (M		: in out Map;
				   Key		: Key_Type;
				   Value	: Value_Type) is
		
		Pos: Natural;
		
	begin
		
		Pos:= Pos_Array(M, Key);
              --cuando clave ya en el array, actualizamos su valor.
		if M.P_Array(Pos).Key = Key then
			M.P_Array(Pos).Value:= Value;
		else --si clave no esta en array, movemos todos los elementos sucesivos una posicion derecha+1                                            
			if M.Length < Max then
				for I in reverse Pos..M.Length-1 loop
					M.P_Array(I+1):= M.P_Array(I);
				end loop;
                      --
				M.P_Array(Pos).Key:= Key;
				M.P_Array(Pos).Value:= Value;
				M.Length:= M.Length + 1;
			end if;
		end if;
		
	end Put;
	

	procedure Delete (M			: in out Map;
					  Key		: in Key_Type;
					  Success	: out Boolean) is
		
		Pos: Natural;
	
	begin
		Success := False;
		Pos:= Pos_Array(M, Key);
		if M.P_Array(Pos).Key = Key then
			for I in Pos+1 ..M.Length-1 loop
				M.P_Array(I):= M.P_Array(I+1);
			end loop;
			M.Length:= M.Length - 1;
			Success:= True;
		end if;
	end Delete;
	
	
	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;
	
	
	function First (M: Map) return Cursor is
		I: Natural := 0;
	begin
		
		return (M => M, Element => 0);
		
	end First;
	

	procedure Next (C: in out Cursor) is
       
	begin
		
		if C.Element < C.M.Length - 1 then
			C.Element := C.Element + 1;
		else 
			C.Element := -1;
		end if;

	end Next;
	

	function Has_Element (C: Cursor) return Boolean is
       
	begin
		if C.M.Length <=0 then
			return False;
		end if;
		if C.Element /= -1 then
			return True;
		else
			return False;
		end if;
   end Has_Element;
	
	function Element (C: Cursor) return Element_Type is

	begin
		if C.Element /= -1 then
			return (Key   => C.M.P_Array(C.Element).Key,
                    Value => C.M.P_Array(C.Element).Value);
		else
			raise No_Element;
		end if;
	end Element;
	

end Ordered_Maps_G;
