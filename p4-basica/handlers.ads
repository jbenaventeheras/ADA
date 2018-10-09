with Lower_Layer_UDP;
with Hash_Maps_G;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Ada.Command_Line;
with Ordered_Maps_g;

package Handlers is
   package LLU renames Lower_Layer_UDP;
	use type LLU.End_Point_Type;
   package ASU renames Ada.Strings.Unbounded;
           use type ASU.Unbounded_String;
   package ACL renames Ada.Command_line;

   HASH_SIZE:   constant := 10;
   type Hash_Range is mod HASH_SIZE;

   function Hash (US: ASU.Unbounded_String) return Hash_Range;
  

      type info is record
      Client_EP_Handler : LLU.End_Point_Type;
      Last_mess : Ada.Calendar.Time;
   end record;	
    
 --Instaciamos el paquete Hash_Maps_G, con un max desde el ACl.Argument(2), siendo el primero el numero de puerto.
 --Se inlcuye la función hash necesaria para combertir el key que en nuestro caso es un nick, se le pasa el Hash_range tipo modular
 --Que se utiliza en el array que contiene una lista enlazada en cada posición.
   package CA_Maps is new Hash_Maps_G (Key_Type   => ASU.Unbounded_String,
                                       Value_Type => info,
                                        "="        =>  ASU."=",
                                        Hash_Range => Hash_Range,
                                        Hash => handlers.Hash,
                                        Max        => Natural'Value(ACL.Argument(2)));

  --instaciamos el paquete Orderer_Maps_G para los clientes antiguos, comparador Unbounded necesario para busqueda en array.
	
   package CI_Maps  is new Ordered_Maps_G (Key_Type   	=> ASU.Unbounded_String,
                      			   Value_Type 	=> Ada.Calendar.Time,
                      			   "="       	=> ASU."=", 
			                   "<"			=> ASU."<",
					   Max 		=> 150);

   --Creamos una variable de cada tipo instanciando sus paquetes(que hemos llamado arriba) creando así una variable(CA_Maps) para
   --activos que sera una tablahash, especificada en Hash_maps_g-ads, y una variable (CI_Maps) para antiguos que sera una array 
   --especificado en ordered_maps_g.ads.

       CA_Map : CA_Maps.Map;
       CI_Map : CI_Maps.Map;  	 	
       
    -- 	NO CONFUDIR CA_Map/CI_Map variable de la lista de clientes activos/antiguos, con CA_Maps/CI_Maps, paquetes instaciados de 
    --  Hash_Maps_G y Ordered_Maps_G. 

   procedure Print_CA_Map (M : CA_Maps.Map);
   procedure Print_CI_Map (M : CI_Maps.Map);
   procedure Search_Oldest (M : in CA_Maps.Map;  Oldest_client: out  ASU.Unbounded_String);

   -- Handler para utilizar como parámetro en LLU.Bind en el servidor
   procedure Server_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);


   -- Handler para utilizar como parámetro en LLU.Bind en el cliente
   -- Muestra en pantalla la cadena de texto recibida
   -- Este procedimiento NO debe llamarse explícitamente
   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);



end Handlers;
