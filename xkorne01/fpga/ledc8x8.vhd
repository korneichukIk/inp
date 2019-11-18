-- Autor reseni: Ivan Korneichuk, xkorne01

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
  port (
    SMCLK, RESET: in std_logic;
    ROW, LED: out std_logic_vector(0 to 7)
  );
end ledc8x8;

architecture main of ledc8x8 is
  signal counter: std_logic_vector(0 to 11) := (others => '0');
  signal ce: std_logic := '0';
  signal stav: std_logic_vector(0 to 1) := "00";
  signal state_change: std_logic_vector(0 to 23) := (others => '0');
  signal leds_active: std_logic_vector(0 to 7) := (others => '1');
  signal rows_active: std_logic_vector(0 to 7) := "10000000";
begin

  counter_gen : process(SMCLK, RESET)
  begin
    if (RESET = '1') then
      counter <= (others => '0');
    elsif (rising_edge(SMCLK)) then
      counter <= counter + 1;
    end if;
  end process counter_gen;
  ce <= '1' when counter = X"FF" else '0';

  state_change_pr: process(SMCLK, RESET)
  begin
    if (RESET = '1') then
      stav <= "00";
    elsif (rising_edge(SMCLK)) then
      if (state_change = X"1C2000") then
        if (stav = "10") then
          null;
        else
          stav <= stav + 1;
          state_change <= (others => '0');
        end if;
      end if;

      state_change <= state_change + 1;
    end if;
  end process state_change_pr;

  rotate : process(ce, SMCLK, RESET)
  begin
    if (RESET = '1') then
      rows_active <= "10000000";
    elsif (rising_edge(SMCLK)) then
      if (ce = '1') then
        rows_active <= rows_active(7) & rows_active(0 to 6);
      end if;
    end if;
  end process rotate;

  run : process(rows_active, stav)
  begin
    if (stav = "00" or stav = "10") then
      case (rows_active) is
        when "10000000" => leds_active <= "00111010";
        when "01000000" => leds_active <= "01011010";
        when "00100000" => leds_active <= "01011010";
        when "00010000" => leds_active <= "01011000";
        when "00001000" => leds_active <= "01011010";
        when "00000100" => leds_active <= "01011010";
        when "00000010" => leds_active <= "01011010";
        when "00000001" => leds_active <= "00111010";
        when others => leds_active <= (others => '1');
      end case;
    else
      leds_active <= (others => '1');
    end if;
  end process;

  LED <= leds_active;
  ROW <= rows_active;
end main;




-- ISID: 75579
