LIBRARY ieee;
USE iee.std_logic_1164.all;

ENTITY simple IS
  PORT(clk_hi, SCL_in, SDA_in, byte_done, addr_match      :IN  STD_LOGIC;
       SDA_out, SDA_enable, data_out, addr_out, nack_sent :OUT STD_LOGIC);
END simple;

ARCHITECTURE beh OF i2c_slave IS
  TYPE state_t IS (SL0, SL1, SL2, SA0, SA1, SA2, SR0, SR1, SR2, SR3, SR4, SRA0, SRA1, SW0, SW1, SW2, SWA0, SWA1);
  signal state: state_t := SL0
BEGIN
  PROCESS (clk_hi)
  BEGIN
    IF (clk_hi'EVENT AND clk_hi = '0') THEN
      exit
    END IF;

    CASE state IS
    END CASE;
  END PROCESS;
END beh;
