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