library ieee;
use ieee.std_logic_1164.all;

entity demo_top is
  port (
    clk     : in std_ulogic;
    myinput : in std_ulogic;
    myoutput : out std_ulogic
    );
end entity demo_top;

architecture structural of demo_top is

begin
  reg : entity work.DFlipflop
    port map (
      clk => clk,
      en  => '1',
      d => myinput,
      q => myoutput
      );
end architecture structural;
      
