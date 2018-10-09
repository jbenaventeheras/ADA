with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Unchecked_Deallocation;

package body Ordered_Maps_G is


	function Calculate_Index (M: Map;
							  Key: Key_Type) 
							  return Integer is
		Index: Integer;
		First: Integer:=0;
		Last: Integer:= M.Length - 1;
	begin

		if M.Length = 0 then
			return First;
		end if;
				
		if M.P_Array(First).Key < Key then
			return M.Length; -- Last + 1
		end if;
		
		if Key < M.P_Array(First).Key then
			return First;
		end if;
		
		while First/= Last loop
			Index:= First + ((Last - First) / 2);
			if M.P_Array(Index).Key < Key then
				First:= Index + 1;
			else
				Last:= Index;
			end if;
		end loop;
		return First;
			

	end Calculate_Index; 	
	
	
	
	-------------------------GET-------------------------
	procedure Get (M		: Map;
				   Key		: in Key_Type;
				   Value	: out Value_Type;
				   Success	: out Boolean) is

		Index: Natural;

	begin
		Success := False;
		Index:= Calculate_Index(M, Key);
		if M.P_Array(Index).Key = Key then
			Value:= M.P_Array(Index).Value;
			Success:= True;
		end if;
			
	end Get;

	-------------------------PUT-------------------------
	procedure Put (M		: in out Map;
				   Key		: Key_Type;
				   Value	: Value_Type) is
		
		Index: Natural;
		
	begin
		
		Index:= Calculate_Index(M, Key);
		if M.P_Array(Index).Key = Key then
			M.P_Array(Index).Value:= Value;
		else                                             --Si la clave del elemento a insertar no está ya en el Array, hay
                                                                 --que mover todos los elementos que le suceden una posición
			if M.Length < Max then
				for I in reverse Index..M.Length-1 loop
					M.P_Array(I+1):= M.P_Array(I);
				end loop;
				M.P_Array(Index).Key:= Key;
				M.P_Array(Index).Value:= Value;
				M.Length:= M.Length + 1;
			end if;
		end if;
		
	end Put;
	
	
	-----------------------DELETE-----------------------
	procedure Delete (M			: in out Map;
					  Key		: in Key_Type;
					  Success	: out Boolean) is
		
		Index: Natural;
	
	begin
		Success := False;
		Index:= Calculate_Index(M, Key);
		if M.P_Array(Index).Key = Key then
			for I in Index+1 ..M.Length-1 loop
				M.P_Array(I):= M.P_Array(I+1);
			end loop;
			M.Length:= M.Length - 1;
			Success:= True;
		end if;
	end Delete;
	
	-------------------------MAP LENGTH-------------------------
	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;
	
	-------------------------FIRST-------------------------
	function First (M: Map) return Cursor is
		I: Natural := 0;
	begin
		
		return (M => M, Element => 0);
		
	end First;
	
	-------------------------NEXT-------------------------
	procedure Next (C: in out Cursor) is
       
	begin
		
		if C.Element < C.M.Length - 1 then
			C.Element := C.Element + 1;
		else 
			C.Element := -1;
		end if;

	end Next;
	
	
	-------------------------HAS ELEMENT------------------------
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
	
	-------------------------ELEMENT-------------------------
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
