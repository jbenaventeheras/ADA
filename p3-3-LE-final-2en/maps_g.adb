with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
		
     

      P_Aux := M.P_First;
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
      P_Aux : Cell_A;
      P_Aux_2 : Cell_A;
      Found : Boolean;
   begin
		
		

      -- Si ya existe Key, cambiamos su Value
      P_Aux := M.P_First;
      Found := False;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;

      -- Si no hemos encontrado Key añadimos al principio
      if not Found and M.length < Max then   
          
         if M.P_First = null then
         M.P_First := new Cell'(Key, Value, M.P_First, null);
     ----cuando creamos la primera la igualamos a P_Last ya que añadimos por delante.
         M.P_Last := M.P_First;
         M.Length := M.Length + 1;
         elsif M.P_First /= null then
           P_Aux_2 :=  M.P_First;
           M.P_First := new Cell'(Key, Value, M.P_First, null);
           P_Aux_2.Prev:=  M.P_First;
            M.Length := M.Length + 1;
         end if;
 
	  elsif not Found and M.length = Max then
			raise Full_Map; 
      end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;

   begin
      Success := False;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Current.Prev /= null then
              P_Current.Prev.Next := P_Current.Next;
            end if;
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
            end if;
            Free (P_Current);
         else
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;


  function Last (M: Map) return Cursor is
   begin
      return (M => M, Element_A => M.P_Last);
   end Last;


   function First (M: Map) return Cursor is
   begin
      return (M => M, Element_A => M.P_First);
   end First;

   procedure Next (C: in out Cursor) is
   begin
      if C.Element_A /= null Then
         C.Element_A := C.Element_A.Next;
      end if;
   end Next;

  procedure Prev (C: in out Cursor) is
   begin
      if C.Element_A /= null Then
         C.Element_A := C.Element_A.Prev;
      end if;
   end Prev;




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


end Maps_G;
