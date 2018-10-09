--
--  TAD genérico de una tabla de símbolos (map) implementada como 
--  un array ordenado con busqueda binaria
--

generic

	type Key_Type is private;
	type Value_Type is private;
	with function "=" (K1, K2: Key_Type) return Boolean;
	with function "<" (K1, K2: Key_Type) return Boolean;
	Max: in Natural;

package Ordered_Maps_G is

	type Map is limited private;
	
	Full_Map : exception;
	
	function Calculate_Index (M: Map;
							  Key: Key_Type) 
							  return Integer;

	procedure Get (M		: Map;
				   Key		: in Key_Type;
				   Value	: out Value_Type;
				   Success	: out Boolean);

	procedure Put (M		: in out Map;
				   Key		: Key_Type;
				   Value	: Value_Type);

	procedure Delete (M			: in out Map;
					  Key		: in Key_Type;
					  Success	: out Boolean);

	function Map_Length (M : Map) return Natural;
	
	--
	-- Cursor Interface for iterating over Map elements
	--
	type Cursor is limited private;
	function First (M: Map) return Cursor;
	procedure Next (C: in out Cursor);
	function Has_Element (C: Cursor) return Boolean;
	type Element_Type is record
		Key: Key_Type;
		Value: Value_Type;
	end record;
	No_Element: exception;
	
	-- Raises No_Element if Has_Element(C) = False;
	function Element (C: Cursor) return Element_Type;

private
	
	type Cell is record
		Key   : Key_Type;
		Value : Value_Type;
	end record;

	type Cell_Array is array (0..Max-1) of Cell;
    type Cell_Array_A is access Cell_Array;

    type Map is record
    	P_Array: Cell_Array_A := new Cell_Array;
    	Length : Natural := 0;
    end record;
	
	type Cursor is record
		M         : Map;
		Element   : Integer;
	end record;
	
end Ordered_Maps_G;
