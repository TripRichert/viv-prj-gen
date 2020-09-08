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
      
--#############################################################################
-- MIT LICENSE
--#############################################################################

--Copyright 2020 Trip Richert

--Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
