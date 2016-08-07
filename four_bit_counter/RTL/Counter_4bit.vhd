library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Counter_4bit is
port(
      clk  : in  std_logic;
		rst  : in  std_logic;
		hlt  : in  std_logic;
		LEDs : out std_logic_vector(3 downto 0)
);
end entity;
architecture behavioural of Counter_4bit is

signal counter              : std_logic_vector(3 downto 0);
signal internal_rst_counter : std_logic_vector(3 downto 0);
signal internal_rst         : std_logic;
signal pulse_counter        : std_logic_vector(31 downto 0);--can be 28 I think
signal pulse                : std_logic;
signal debounce_reg_rst     : std_logic_vector(2 downto 0);
signal debounce_reg_hlt     : std_logic_vector(2 downto 0);
signal rst_dr               : std_logic;
signal hlt_dr               : std_logic;
begin

process(clk) --internal reset logic
begin
if(rising_edge(clk))then
  if(internal_rst_counter<x"E")then
    internal_rst_counter<=internal_rst_counter+x"1";
	 internal_rst<='1';
  else
    internal_rst<='0';
  end if;
end if;
end process;

process(clk)--Pulse logic
begin
if(rising_edge(clk))then
  if(pulse_counter<x"5F5E100")then
    pulse_counter<=pulse_counter+x"1";
	 pulse<='0';
  else
    pulse_counter<=(others=>'0');
    pulse<='1';
  end if;
end if;
end process;

process(clk) --Double registering logic.This can ignore for now.
begin        --It's used to eliminate metastability issues.
  if(rising_edge(clk))then
    debounce_reg_rst <= debounce_reg_rst(1 downto 0) & rst;
    debounce_reg_hlt <= debounce_reg_hlt(1 downto 0) & hlt;
  end if;
end process;
rst_dr <= debounce_reg_rst(2);
hlt_dr <= debounce_reg_hlt(2);


process(clk,pulse,rst_dr,internal_rst)
begin
if(rising_edge(clk))then
  if(internal_rst='1' or rst_dr='1')then
    counter<=(others=>'0');
  elsif(pulse='1' and hlt_dr='1')then
    counter<=counter+x"1";
  end if;
end if;
end process;
LEDs <=counter;

end behavioural;
