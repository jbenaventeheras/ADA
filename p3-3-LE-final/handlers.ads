with Lower_Layer_UDP;
with Maps_G;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Ada.Command_Line;

package Handlers is
   package LLU renames Lower_Layer_UDP;
	use type LLU.End_Point_Type;
   package ASU renames Ada.Strings.Unbounded;
           use type ASU.Unbounded_String;
   package CL renames Ada.Command_line;
	
   type info is record
      Client_EP_Handler : LLU.End_Point_Type;
      Last_mess : Ada.Calendar.Time;
   end record;	
    

   package CA_Maps is new Maps_G (Key_Type   => ASU.Unbounded_String,
                               Value_Type => info,
         
                      "="        =>  ASU."=",
                      Max        =>   Integer'Value(CL.Argument(2)) );
	

   package CI_Maps is new Maps_G (Key_Type   => ASU.Unbounded_String,
                                  Value_Type => Ada.Calendar.Time,
         
                      "="        => ASU."=",
                      Max        => 150              );

       CA_Map : CA_Maps.Map;
       CI_Map : CI_Maps.Map;  	 	
       

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
