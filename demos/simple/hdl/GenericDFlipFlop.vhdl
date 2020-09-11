library ieee;
use ieee.std_logic_1164.all;

entity GenericDFlipFlop is
generic (
    width : natural := 8;
    edge  : std_ulogic := '1'
);
port (
    clk : in std_ulogic;
    en  : in std_ulogic;
    d : in std_ulogic_vector(width - 1 downto 0);
    q : out std_ulogic_vector(width - 1 downto 0)
);
end entity GenericDFlipFlop;

architecture behavioral of GenericDFlipFlop is
begin

    process(clk)
    begin
        if clk'event and clk = edge and clk'last_value = not edge then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture behavioral;

--#############################################################################
-- MIT LICENSE
--#############################################################################

--Copyright 2020 Trip Richert

--Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
