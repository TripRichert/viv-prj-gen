library ieee;
use ieee.std_logic_1164.all;

entity DFlipFlop is
port (
    clk : in std_ulogic;
    en  : in std_ulogic;
    d : in std_ulogic;
    q : out std_ulogic
);
end entity DFlipFlop;

architecture behavioral of DFlipFlop is
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture behavioral;