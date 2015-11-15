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
      WHEN SL0 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SL1;
        ELSE
          state <= SL0;
        END IF
      WHEN SL1 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SL1;
        ELSIF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SL2;
        ELSIF (SCL_in = '0') THEN
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF
      WHEN SL2 =>
        IF (SCL_in = '0') THEN
          state <= SA0;
        ELSIF (SCL_in = '1') THEN
          state <= SL2;
        END IF
      WHEN SA0 =>
        IF (SCL_in = '0') THEN
          state <= SA0;
        ELSIF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SA1;
        ELSIF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SA2;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF
      WHEN SA1 =>
        IF (SDA_in = '0' AND SCL_in = '1') THEN
          state <= SA1;
        ELSIF (SCL_in = '0' AND addr_match = '1') THEN
          assert byte_done == '1' report "byte_done not high" severity ERROR;
          state <= SW0;
        ELSIF (SCL_in = '0' AND addr_match = '0') THEN
          assert byte_done == '1' report "byte_done not high" severity ERROR;
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF
      WHEN SA2 =>
        IF (SDA_in = '1' AND SCL_in = '1') THEN
          state <= SA2;
        ELSIF (SCL_in = '0' AND addr_match = '1') THEN
          assert byte_done == '1' report "byte_done not high" severity ERROR;
          state <= SR0;
        ELSIF (SCL_in = '0' AND addr_match = '0') THEN
          assert byte_done == '1' report "byte_done not high" severity ERROR;
          state <= SL0;
        ELSE
          assert false report "unexpected state" severity FAILURE;
        END IF


          when SW0 =>
        if SCL_in = '0' then
          state <= SW0;
        elsif SDA_in = '0' and SCL_in = '1' then
          state <= SW1;
        elsif SDA_in = '1' and SCL_in = '1' then
          state <= SW2;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SW1 =>
        if SDA_in = '1' and SCL_in = '1' then
          state <= SW1;
        elsif SCL_in = '0' and byte_done = '0' then
          state <= SW0;
        elsif SCL_in = '0' and byte_done = '1' then
          state <= SWA0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SW2 =>
        if SDA_in = '0' and SCL_in = '1' then
          state <= SW0;
        elsif SDA_in = '1' and SCL_in = '1' then
          state <= SL0; 
        elsif SCL_in = '0' and byte_done = '0' then
          state <= SW0;
        elsif SCL_in = '0' and byte_done = '1' then
          state <= SWA0;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SWA0 =>
        if SCL_in = '0' then
          state <= SWA0;
        elsif SCL_in = '1' then
          state <= SWA1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
      when SWA1 =>
        if SCL_in = '0' then
          state <= SW0;
        elsif SCL_in = '1' then
          state <= SWA1;
        else
          assert false report "unexpected state" severity ERROR;
        end if;
    END CASE;
  END PROCESS;
END beh;
