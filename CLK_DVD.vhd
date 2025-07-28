library IEEE;
use IEEE.std_logic_1164.all;



entity CLK_DVD is
port(CLK_IN : in std_logic; -- Input clock
 
RSTN : in std_logic; -- Active low reset
CLK_OUT : out std_logic); -- Output clock
end entity;


architecture FUNCTIONALITY of CLK_DVD is

signal CNT : integer := 1;
signal TEMP : std_logic := '0';
begin
process(CLK_IN, RSTN)
begin
if (RSTN = '0') then
CNT <= 1;
TEMP <= '0';
elsif (CLK_IN'event and CLK_IN = '1') then
CNT <= CNT+1;
if (CNT = 25000000) then

--if (CNT = 50000000) then
TEMP <= not TEMP;
CNT <= 1;
end if;
end if;
CLK_OUT <= TEMP;
end process;

end architecture;
